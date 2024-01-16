import QtQuick 2.0
import QtQuick.LocalStorage 2.0
import Sailfish.Silica 1.0
import "pages"
import "database.js" as DBHandler

ApplicationWindow {
    id: screentime
    initialPage: Component { FirstPage { } }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: defaultAllowedOrientations

    // Initialization of database
    Component.onCompleted: {
        console.log("Application launched. Performing initialization...");
        // Check that app folder exists
        var appFolder = StandardPaths.data;
        console.log('Appfolder:', appFolder);
        // Init database
        // Init straight away QtQuick.LocalStorage?
        // No need to check paths or anything?
        // https://doc.qt.io/qt-5/qtquick-localstorage-qmlmodule.html
        DBHandler.initializeDatabase();
    }
}
