import QtQuick 2.0
import QtQuick.LocalStorage 2.0
import Sailfish.Silica 1.0
import "pages"
import "database.js" as DB

ApplicationWindow {
    id: screentime
    initialPage: Component { FirstPage { } }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: defaultAllowedOrientations

    Component.onDestruction: {
        console.log("Application closing");
        DB.insertEvent("off");
    }
}
