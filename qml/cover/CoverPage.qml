import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0
import "../database.js" as DB

CoverBackground {
    // Init the time label
    Component.onCompleted: {
        timeOnLabel.text = DB.getScreenOnTime(new Date());
        timeOnAvgLabel.text = DB.getAverageScreenOnTime(new Date());
    }
    // Update the screen on time every minute
    Timer {
        interval: 60000
        repeat: true
        running: true
        onTriggered: {
            timeOnLabel.text = DB.getScreenOnTime(new Date());
            // Update the previous 7 day average if it's midnight
            var now = new Date();
            if (now.getHours() === 0 && now.getMinutes() === 0) {
                console.log("Midnight, recalculating average.");
                timeOnAvgLabel.text = DB.getAverageScreenOnTime(new Date());
            }
        }
    }

    Label {
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        text: "Screen time"
    }
    Label {
        anchors.bottom: timeOnLabel.top
        anchors.horizontalCenter: parent.horizontalCenter
        text: "Today"
    }
    Label {
        id: timeOnLabel
        anchors.centerIn: parent
        font.pixelSize: Theme.fontSizeHuge
        text: "HH:MM"
    }
    Label {
        anchors.bottom: timeOnAvgLabel.top
        anchors.horizontalCenter: parent.horizontalCenter
        text: "7 days avg"
    }
    Label {
        id: timeOnAvgLabel
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        text: "HH:MM"
    }
}
