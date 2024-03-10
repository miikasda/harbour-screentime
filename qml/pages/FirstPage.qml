import QtQuick 2.0
import Nemo.DBus 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0
import "../database.js" as DB
import "../modules/GraphData"
import ".."

Page {
    id: page

    property string displayStatus: "on"
    property string avgUpdated: new Date().toDateString()

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    function updateGraph() {
        var eventData = DB.getData(new Date());
        screenEventGraph.setPoints(eventData);
        var cumulativeData = DB.getCumulativeUsage(new Date());
        screenCumulativeGraph.setPoints(cumulativeData);
    }

    // Init the database and time labels
    Component.onCompleted: {
        DB.initializeDatabase()
        var now = new Date();
        LabelData.screenOnToday = DB.getScreenOnTime(new Date())
        LabelData.weeklyAvg = DB.getAverageScreenOnTime(new Date());
        updateGraph();
    }

    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaFlickable {
        anchors.fill: parent

        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
        PullDownMenu {
            MenuItem {
                text: "Show Page 2"
                onClicked: pageStack.animatorPush(Qt.resolvedUrl("SecondPage.qml"))
            }
        }

        // Check the screen state every second
        DBusInterface {
            id: mce

            bus: DBus.SystemBus
            service: 'com.nokia.mce'
            iface: 'com.nokia.mce.request'
            path: '/com/nokia/mce/request'
        }
        Timer {
            interval: 1000 // Check every 1000 milliseconds (1 second)
            repeat: true
            running: true

            onTriggered: {
                mce.typedCall('get_display_status', [], function (result) {
                    if(displayStatus !== result){
                        if (result === "on" || result === "off") {
                            console.log('Display status changed to', result);
                            DB.insertEvent(result);
                            displayStatus = result;
                        }
                    }
                });
            }
        }

        // Update the screen on time every minute
        Timer {
            interval: 60000
            repeat: true
            running: true
            onTriggered: {
                // Update todays label data
                var now = new Date();
                LabelData.screenOnToday = DB.getScreenOnTime(now);
                // Update the graph
                console.log("Minute timer trigger");
                updateGraph();
                // Update the previous 7 day average if the day has changed
                if (now.toDateString() !== avgUpdated) {
                    console.log("Day changed, recalculating average");
                    avgUpdated = now.toDateString();
                    LabelData.weeklyAvg = DB.getAverageScreenOnTime(now);
                }
            }
        }

        // Tell SilicaFlickable the height of its content.
        contentHeight: column.height

        // Place our content in a Column.  The PageHeader is always placed at the top
        // of the page, followed by our content.
        Column {
            id: column

            width: page.width
            spacing: Theme.paddingMedium
            PageHeader {
                title: "Screen time"
            }
            GraphData {
                id: screenEventGraph
                graphTitle: "Screen events"
                width: parent.width
                scale: true
                axisY.units: "On"
                flatLines: true
            }
            GraphData {
                id: screenCumulativeGraph
                graphTitle: "Cumulative usage"
                width: parent.width
                scale: true
                axisY.units: "Min"
                flatLines: false
            }
            SectionHeader {
                text: "Durations (HH:MM)"
            }
            DetailItem {
               id: timeOnLabel
               label: "Screen on today"
               value: LabelData.screenOnToday
            }
            DetailItem {
               id: timeOnAvgLabel
               label: "7 previous days average"
               value: LabelData.weeklyAvg
            }
        }
        onVisibleChanged: {
            if (status === PageStatus.Active & visible) {
                // Lines are not shown when app is background
                // redraw the graphs when the page is visible again
                updateGraph();
            }
        }
    }
}
