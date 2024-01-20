var db = LocalStorage.openDatabaseSync("screenData.sqlite");

function initializeDatabase() {
    db.transaction(
        function(tx) {
            tx.executeSql('CREATE TABLE IF NOT EXISTS events(timestamp INT, powered INT)');
            insertEvent("on")
        }
    );
    console.log("Initialized database")
}

function getLatestEvent() {
    var latestValue;
    var latestTimestamp;
    db.transaction(
        function(tx) {
            var result = tx.executeSql('SELECT timestamp, powered FROM events ORDER BY timestamp DESC LIMIT 1');
            if (result.rows.length > 0) {
                latestTimestamp = result.rows.item(0).timestamp;
                latestValue = result.rows.item(0).powered;
            } else {
                latestTimestamp = "emptydb"
                latestValue = "emptydb"
            }
        }
    );
    return [latestTimestamp, latestValue];
}

function getScreenOnTime(date) {
    var screenOnTime;
    date.setHours(0, 0, 0, 0);
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
                            AND timestamp >= ? \
                        ) - \
                        ( \
                            SELECT MAX(timestamp) \
                            FROM events \
                            WHERE powered = 1 \
                            AND timestamp <= e.timestamp \
                            AND timestamp >= ? \
                        ) as durations \
                    FROM \
                        events e \
                    WHERE \
                        powered = 0 \
                        AND timestamp >= ? \
                )',
                [date.getTime(), date.getTime(), date.getTime()]
            );
            screenOnTime = result.rows.item(0).total_screen_on;
        }
    );
    // If the screen is now on, we need to add time from start of this session to now
    var latestValues = getLatestEvent()
    if (latestValues[1] === 1) {
        screenOnTime = screenOnTime + ((new Date().getTime() - latestValues[0]) / 1000);
    }
    // screenOnTime is currently in seconds, return as HH:MM:SS string
    screenOnTime = screenOnTime.toFixed();
    var hours = Math.floor(screenOnTime / 3600);
    var minutes = Math.floor((screenOnTime % 3600) / 60);
    // Add Leading zeros
    var formattedHours = hours < 10 ? "0" + hours : hours;
    var formattedMinutes = minutes < 10 ? "0" + minutes : minutes;
    return formattedHours + ":" + formattedMinutes;
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
    if (latestEvent !== eventInt) {
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
