import QtQuick 2.0
import Nemo.DBus 2.0
import Sailfish.Silica 1.0
Page {
    id: page

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    // SQL functions
    function insert_event(timestamp, event) {
        // Convert event from str to int
        var eventInt
        switch(event) {
            case "off":
                eventInt = 0
                break
            case "on":
                eventInt = 1
                break
        }
        console.log("eventInt: ", eventInt)
	//screentime.db.transaction()
    }

    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaFlickable {
        anchors.fill: parent

        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
        PullDownMenu {
            MenuItem {
                text: qsTr("Show Page 2")
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
                    console.log('D-Bus call result:', result);
                    insert_event(1, result);
                });
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
                title: qsTr("UI Template")
            }
            Label {
                x: Theme.horizontalPageMargin
                text: qsTr("Hello Sailors")
                color: Theme.secondaryHighlightColor
                font.pixelSize: Theme.fontSizeExtraLarge
            }
        }
    }
}
