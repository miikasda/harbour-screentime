import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0
import "../database.js" as DB

CoverBackground {
    // Init the time label
    Component.onCompleted: {
        timeOnLabel.text = DB.getScreenOnTime();
    }
    // Update the screen on time every minute
    Timer {
        interval: 60000
        repeat: true
        running: true
        onTriggered: {
            timeOnLabel.text = DB.getScreenOnTime();
        }
    }

    Label {
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        text: "Screen time"
    }
    Label {
        id: timeOnLabel
        anchors.centerIn: parent
        font.pixelSize: Theme.fontSizeHuge
        text: "HH:MM"
    }
}
