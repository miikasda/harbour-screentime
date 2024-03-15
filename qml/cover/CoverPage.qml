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
        visible: LabelData.showScreenOn === 1 || LabelData.showWakeCount === 1
    }
    Label {
        id: timeOnLabel
        anchors.centerIn: parent
        font.pixelSize: Theme.fontSizeHuge
        text: LabelData.screenOnToday
        visible: LabelData.showScreenOn === 1
    }
    DetailItem {
       anchors.top: timeOnLabel.bottom
       anchors.horizontalCenter: parent.horizontalCenter
       label: "Wakes"
       value: LabelData.wakeCount
       visible: LabelData.showWakeCount === 1
    }
    Label {
        anchors.bottom: timeOnAvgLabel.top
        anchors.horizontalCenter: parent.horizontalCenter
        text: "7 Days avg"
        visible: LabelData.showAverage === 1
    }
    Label {
        id: timeOnAvgLabel
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        text: LabelData.weeklyAvg
        visible: LabelData.showAverage === 1
    }
}
