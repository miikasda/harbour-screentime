var db = LocalStorage.openDatabaseSync("screenData.sqlite");

function initializeDatabase() {
    db.transaction(
        function(tx) {
            tx.executeSql('CREATE TABLE IF NOT EXISTS events(timestamp INT, powered INT)');
            insertEvent("on")
        }
    );
}

function getLatestEvent() {
    var latestValue;
    var latestTimestamp;
    db.transaction(
        function(tx) {
            var result = tx.executeSql('SELECT timestamp, powered FROM events ORDER BY timestamp DESC LIMIT 1');
            latestTimestamp = result.rows.item(0).timestamp;
            latestValue = result.rows.item(0).powered;
        }
    );
    return [latestTimestamp, latestValue];
}

function getScreenOnTime() {
    var screenOnTime;
    db.transaction(
        function(tx) {
            var result = tx.executeSql('\
                SELECT \
                    SUM(durations / 1000) as total_screen_on \
                FROM ( \
                    SELECT \
                        ( \
                            SELECT MAX(timestamp) \
                            FROM events \
                            WHERE powered = 0 \
                            AND timestamp <= e.timestamp \
                        ) - \
                        ( \
                            SELECT MAX(timestamp) \
                            FROM events \
                            WHERE powered = 1 \
                            AND timestamp <= e.timestamp \
                        ) as durations \
                    FROM \
                        events e \
                    WHERE \
                        powered = 0 \
                )'
            );
            screenOnTime = result.rows.item(0).total_screen_on;
        }
    );
    // If the screen is now on, we need to add time from start of this session to now
    var latestValues = getLatestEvent()
    if (latestValues[1] === 1) {
        screenOnTime = screenOnTime + ((new Date().getTime() - latestValues[0]) / 1000);
    }
    return screenOnTime.toFixed();
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
    // Only insert if current event is other than the latest in DB
    var latestEvent = getLatestEvent()[1];
    if (latestEvent !== event) {
        db.transaction(
            function(tx) {
                var timestamp = new Date().getTime();
                tx.executeSql('INSERT INTO events(timestamp, powered) VALUES (?, ?)', [timestamp, eventInt]);
            }
        );
    }
}

function getDatabase() {
    return db;
}
