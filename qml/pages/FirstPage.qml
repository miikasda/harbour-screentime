import QtQuick 2.0
import Nemo.DBus 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0
import "../database.js" as DB

Page {
    id: page

    property string displayStatus: "on"

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    // Init the time label
    Component.onCompleted: {
        timeOnLabel.text = DB.getScreenOnTime(new Date())
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
                timeOnLabel.text = DB.getScreenOnTime(new Date());
            }
        }

        // Tell SilicaFlickable the height of its content.
        contentHeight: column.height

        // Place our content in a Column.  The PageHeader is always placed at the top
        // of the page, followed by our content.
        Column {
            id: column

            width: page.width
            spacing: Theme.paddingLarge
            PageHeader {
                title: "Screen time today"
            }
            Label {
                x: Theme.horizontalPageMargin
                text: "HH:MM"
                color: Theme.secondaryHighlightColor
                font.pixelSize: Theme.fontSizeExtraLarge
            }
            Label {
               id: timeOnLabel
               x: Theme.horizontalPageMargin
               color: Theme.secondaryHighlightColor
               font.pixelSize: Theme.fontSizeExtraLarge
               text: "00:00"
           }
        }
    }
}
