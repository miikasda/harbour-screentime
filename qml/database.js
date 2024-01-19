var db = LocalStorage.openDatabaseSync("screenData.sqlite");

function initializeDatabase() {
    db.transaction(
        function(tx) {
            tx.executeSql('CREATE TABLE IF NOT EXISTS events(timestamp INT, powered INT)');
            var timestamp = new Date().getTime();
            tx.executeSql('INSERT INTO events(timestamp, powered) VALUES (?, ?)', [timestamp, 1]);
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

function insertEvent(event) {
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
    db.transaction(
        function(tx) {
            var timestamp = new Date().getTime();
            tx.executeSql('INSERT INTO events(timestamp, powered) VALUES (?, ?)', [timestamp, eventInt]);
        }
    );
}

function getDatabase() {
    return db;
}
