import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0
import ".."

CoverBackground {
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
        text: LabelData.screenOnToday
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
        text: LabelData.weeklyAvg
    }
}
