var db = LocalStorage.openDatabaseSync("screenData.sqlite");

function initializeDatabase() {
    db.transaction(
        function(tx) {
            tx.executeSql('CREATE TABLE IF NOT EXISTS events(timestamp INT, powered INT)');
            var result = tx.executeSql('SELECT COUNT(*) AS count FROM events');
            var rowCount = result.rows.item(0).count;
            // TODO we should allways append display on status when the app is lauched
            if (rowCount === 0) {
                console.log("The table is empty, initializing..");
                var currentTimestamp = new Date().getTime();
                tx.executeSql('INSERT INTO events(timestamp, powered) VALUES (?, ?)', [currentTimestamp, 1]);
            } else {
                console.log("The table is not empty, rows: ", rowCount);
            }
        }
    );
}

// TODO Currently not used, remove if there doesnt become new usecases
function getLatestEvent() {
    var latestValue;
    db.transaction(
        function(tx) {
            var result = tx.executeSql('SELECT powered FROM events ORDER BY timestamp DESC LIMIT 1');
            latestValue = result.rows.item(0).powered;
        }
    );
    return latestValue;
}

function insertEvent(timestamp, event) {
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
}

function getDatabase() {
    return db;
}
