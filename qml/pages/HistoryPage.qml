import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0
import "../database.js" as DB
import "../modules/GraphData"

Page {
    id: historyPage
    property var date

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    function updateGraph() {
        var eventData = DB.getPoweredEvents(date);
        screenEventGraph.setPoints(eventData);
        var cumulativeData = DB.getCumulativeUsage(date);
        screenCumulativeGraph.setPoints(cumulativeData);
    }

    // Load data
    Component.onCompleted: {
        updateGraph();
    }

    // Place our content in a Column.  The PageHeader is always placed at the top
    // of the page, followed by our content.
    Column {
        id: column

        width: page.width
        spacing: Theme.paddingMedium
        PageHeader {
            title: date.toLocaleDateString(Qt.locale())
        }
        GraphData {
            id: screenEventGraph
            graphTitle: "Screen status"
            width: parent.width
            scale: false
            axisY.units: ""
            flatLines: true
        }
        GraphData {
            id: screenCumulativeGraph
            graphTitle: "Cumulative usage"
            width: parent.width
            scale: true
            axisY.units: "Minutes"
            flatLines: false
        }
        SectionHeader {
            text: "Durations (HH:MM)"
        }
        DetailItem {
           id: timeOnLabel
           label: "Screen on"
           value: DB.getScreenOnTime(date)
        }
        DetailItem {
           id: timeOnAvgLabel
           label: "7 previous days average"
           value: DB.getAverageScreenOnTime(date);
        }
        SectionHeader {
            text: "Other"
        }
        DetailItem {
           id: wakeCountLabel
           label: "Screen wakes"
           value: DB.getWakeCount(date);
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
