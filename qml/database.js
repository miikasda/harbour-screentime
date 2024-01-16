var db = LocalStorage.openDatabaseSync("screenData.sqlite");

function initializeDatabase() {
    db.transaction(
        function(tx) {
            tx.executeSql('CREATE TABLE IF NOT EXISTS events(timestamp INT, powered INT)');
            var result = tx.executeSql('SELECT COUNT(*) AS count FROM events');
            var rowCount = result.rows.item(0).count;
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

function getDatabase() {
    return db;
}
