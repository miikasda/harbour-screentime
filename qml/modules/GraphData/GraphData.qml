import QtQuick 2.0
import QtQml 2.1
import Sailfish.Silica 1.0

import "."

Item {
    id: root
    anchors {
        left: (parent)? parent.left : undefined
        right: (parent)? parent.right : undefined
    }
    height: graphHeight + (doubleAxisXLables ? Theme.itemSizeMedium : Theme.itemSizeSmall)

    signal clicked

    property alias clickEnabled: backgroundArea.enabled
    property string graphTitle: ""
    property bool flatLines: false

    property alias axisX: _axisXobject
    Axis {
        id: _axisXobject
        mask: "hh:mm"
        grid: 4
    }

    property alias axisY: _axisYobject
    Axis {
        id: _axisYobject
        mask: "%1"
        units: "%"
        grid: 4
    }

    property var valueConverter
    property bool valueTotal: false

    property int graphHeight: 250
    property int graphWidth: canvas.width / canvas.stepX
    property bool doubleAxisXLables: false

    property bool scale: false
    property color lineColor: Theme.highlightColor
    property int lineWidth: 3

    property real minY: 0 //Always 0
    property real maxY: 0

    property int minX: 0
    property int maxX: 0

    property var points: []
    onPointsChanged: {
        noData = (points.length == 0);
    }
    property bool noData: true

    function setPoints(data) {
        if (!data) return;

        var pointMaxY = Number.NEGATIVE_INFINITY;
        var pointMinY = Number.POSITIVE_INFINITY
        if (data.length > 0) {
            minX = data[0].x;
            maxX = data[data.length-1].x;
        }
        data.forEach(function(point) {
            if (point.y > pointMaxY) {
                pointMaxY = point.y
            }
            if (point.y < pointMinY) {
                pointMinY = point.y
            }
        });
        points = data;
        if (scale) {
            // Set the y-axis limits to nearest integer
            maxY = Math.ceil(pointMaxY);
            minY = Math.floor(pointMinY)
        } else {
            // Use [0, 1] y-axis interval
            maxY = 1
            minY = 0
        }

        doubleAxisXLables = ((maxX - minX) > 129600); // 1,5 days

        canvas.requestPaint();
    }

    function createYLabel(value) {
        if (!scale) {
            // Labels for screenEventGraph
            if (value === 1) {
                return "On";
            } else if (value === 0) {
                return "Off";
            } else {
                return "";
            }
        } else {
            // Labels for screenCumulativeGraph
            var v = value;
            if (valueConverter) {
                v = valueConverter(value);
            }
            return axisY.mask.arg(v);
        }
    }

    function createXLabel(value) {
        var d = new Date(value*1000);
        return Qt.formatTime(d, axisX.mask);
    }

    Column {
        anchors {
            top: parent.top
            left: parent.left
            leftMargin: 3*Theme.paddingLarge
            right: parent.right
            rightMargin: Theme.paddingLarge
        }

        Label {
            width: parent.width
            color: Theme.highlightColor
            font.pixelSize: Theme.fontSizeSmall
            text: graphTitle
            wrapMode: Text.Wrap

            Label {
                id: labelLastValue
                anchors {
                    right: parent.right
                }
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.Wrap
                visible: !noData
            }
        }

        Rectangle {
            width: parent.width
            height: graphHeight
            border.color: Theme.secondaryHighlightColor
            color: "transparent"

            BackgroundItem {
                id: backgroundArea
                anchors.fill: parent
                onClicked: {
                    root.clicked();
                }
            }

            Repeater {
                model: noData ? 0 : (axisY.grid + 1)
                delegate: Label {
                    color: Theme.primaryColor
                    font.pixelSize: Theme.fontSizeLarge / 2
                    text: createYLabel( (maxY-minY)/axisY.grid * index + minY)
                    anchors {
                        top: (index == axisY.grid) ? parent.top : undefined
                        bottom: (index == axisY.grid) ? undefined : parent.bottom
                        bottomMargin: (index) ? parent.height / axisY.grid * index - height/2 : 0
                        right: parent.left
                        rightMargin: Theme.paddingSmall
                    }
                }
            }

            Repeater {
                model: noData ? 0 : (axisX.grid + 1)
                delegate: Label {
                    color: Theme.primaryColor
                    font.pixelSize: Theme.fontSizeLarge / 2
                    text: createXLabel( (maxX-minX)/axisX.grid * index + minX )
                    anchors {
                        top: parent.bottom
                        topMargin: Theme.paddingSmall
                        left: (index == axisX.grid) ? undefined : parent.left
                        right: (index == axisX.grid) ? parent.right : undefined
                        leftMargin: (index) ? (parent.width / axisX.grid * index - width/2): 0
                    }
                    Label {
                        color: Theme.primaryColor
                        font.pixelSize: Theme.fontSizeLarge / 2
                        anchors {
                            top: parent.bottom
                            horizontalCenter: parent.horizontalCenter
                        }
                        text: Qt.formatDate(new Date( ((maxX-minX)/axisX.grid * index + minX) * 1000), "ddd dd.MM");
                        visible: doubleAxisXLables
                    }
                }
            }

            Label {
                color: Theme.primaryColor
                font.pixelSize: Theme.fontSizeLarge / 2
                text: axisY.units
                anchors {
                    top: parent.top
                    left: parent.left
                    leftMargin: Theme.paddingSmall
                }
                visible: !noData
            }

            Canvas {
                id: canvas
                anchors {
                    fill: parent
                    //leftMargin: Theme.paddingSmall
                    //rightMargin: Theme.paddingSmall
                }

                //renderTarget: Canvas.FramebufferObject
                //renderStrategy: Canvas.Threaded

                property real stepX: parent.width / (points.length - 1)
                property real stepY: (maxY-minY)/(height-2)

                function drawGrid(ctx) {
                    ctx.save();

                    ctx.lineWidth = 1;
                    ctx.strokeStyle = lineColor;
                    ctx.globalAlpha = 0.4;
                    //i=0 and i=axisY.grid skipped, top/bottom line
                    for (var i=1;i<axisY.grid;i++) {
                        ctx.beginPath();
                        ctx.moveTo(0, height/axisY.grid * i);
                        ctx.lineTo(width, height/axisY.grid * i);
                        ctx.stroke();
                    }

                    ctx.restore();
                }

                //TODO: allow multiple lines to be drawn
                function drawPoints(ctx, points) {
                }

                onPaint: {
                    var ctx = canvas.getContext("2d");
                    if (flatLines) {
                        ctx.globalCompositeOperation = "source-over";
                        ctx.clearRect(0, 0, width, height);

                        // Draw grid lines
                        drawGrid(ctx);

                        // Draw data points
                        ctx.save();
                        ctx.strokeStyle = lineColor;
                        ctx.lineWidth = lineWidth;
                        ctx.beginPath();

                        var startX = Math.floor((points[0].x - minX) / (maxX - minX) * width);
                        var startY = height - Math.floor((points[0].y - minY) / stepY) - 1;

                        for (var i = 1; i < points.length; i++) {
                            var point = points[i];
                            var endX = Math.floor((point.x - minX) / (maxX - minX) * width);
                            var endY = height - Math.floor((point.y - minY) / stepY) - 1;

                            // Draw line segment from previous point to current point
                            ctx.moveTo(startX, startY);
                            ctx.lineTo(endX, startY);
                            ctx.stroke();

                            // Draw line segment at the current value level
                            ctx.moveTo(endX, startY);
                            ctx.lineTo(endX, endY);
                            ctx.stroke();

                            // Update start coordinates for the next segment
                            startX = endX;
                            startY = endY;
                        }

                        ctx.restore();
                    } else {
                        ctx.globalCompositeOperation = "source-over";
                        ctx.clearRect(0, 0, width, height);

                        // Draw grid lines
                        drawGrid(ctx);

                        // Draw data points
                        ctx.save();
                        ctx.strokeStyle = lineColor;
                        ctx.lineWidth = lineWidth;
                        ctx.beginPath();

                        var startX = Math.floor((points[0].x - minX) / (maxX - minX) * width);
                        var startY = height - Math.floor((points[0].y - minY) / stepY) - 1;

                        // Move pen to the starting point
                        ctx.moveTo(startX, startY);

                        for (var i = 1; i < points.length; i++) {
                            var point = points[i];
                            var endX = Math.floor((point.x - minX) / (maxX - minX) * width);
                            var endY = height - Math.floor((point.y - minY) / stepY) - 1;

                            // Draw line segment from previous point to current point
                            ctx.lineTo(endX, endY);
                        }

                        // Stroke the entire path at once
                        ctx.stroke();

                        ctx.restore();
                    }
                }
            }

            Text {
                id: textNoData
                anchors.centerIn: parent
                color: lineColor
                text: qsTr("No data");
                visible: noData
            }
        }
    }
}
