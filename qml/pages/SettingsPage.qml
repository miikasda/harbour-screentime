import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0
import "../database.js" as DB
import ".."

Page {
    Column {
        width: page.width
        spacing: Theme.paddingMedium
        PageHeader {
            title: "Settings"
        }
        SectionHeader {
            text: "App Cover"
        }
        TextSwitch {
            text: "Show screen on time"
            checked: LabelData.showScreenOn === 1
            onCheckedChanged: {
                var intValue = checked  ? 1 : 0;
                DB.setSettingValue("showScreenOn", intValue);
                LabelData.showScreenOn = intValue
            }
        }
        TextSwitch {
            text: "Show wake count"
            checked: LabelData.showWakeCount === 1
            onCheckedChanged: {
                var intValue = checked  ? 1 : 0;
                DB.setSettingValue("showWakeCount", intValue);
                LabelData.showWakeCount = intValue
            }
        }
        TextSwitch {
            text: "Show average"
            checked: LabelData.showAverage === 1
            onCheckedChanged: {
                var intValue = checked  ? 1 : 0;
                DB.setSettingValue("showAverage", intValue);
                LabelData.showAverage = intValue
            }
        }
    }
}
