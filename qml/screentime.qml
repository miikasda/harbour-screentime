import QtQuick 2.0
import QtQuick.LocalStorage 2.0
import Sailfish.Silica 1.0
import "pages"

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
        var db = LocalStorage.openDatabaseSync("screenData.sqlite");
        db.transaction(
           function(tx) {
               // Create the database if it doesn't already exist
               tx.executeSql('CREATE TABLE IF NOT EXISTS events(timestamp INT, powered INT)');
           }
       )
    }
}
