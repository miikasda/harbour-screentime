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

function secondsToString(seconds) {
    // Round to full seconds
    seconds = seconds.toFixed()
    // Converts seconds to HH:MM string and returns it
    var hours = Math.floor(seconds / 3600);
    var minutes = Math.floor((seconds % 3600) / 60);
    // Add Leading zeros
    var formattedHours = hours < 10 ? "0" + hours : hours;
    var formattedMinutes = minutes < 10 ? "0" + minutes : minutes;
    return formattedHours + ":" + formattedMinutes;
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
    var screenOnTime = null;
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
                        AND timestamp < ? + 86400000 /* 24 hours in milliseconds */ \
                )',
                [date.getTime(), date.getTime(), date.getTime(), date.getTime()]
            );
            screenOnTime = result.rows.item(0).total_screen_on;
        }
    );
    // If the screen is now on, and we are calculating for today we need to add time from start of this session to now
    var latestValues = getLatestEvent()
    if (latestValues[1] === 1 && date.getTime() === new Date().setHours(0, 0, 0, 0)) {
        screenOnTime = screenOnTime + ((new Date().getTime() - latestValues[0]) / 1000);
    }
    // screenOnTime is currently in seconds, return as HH:MM:SS string
    if (screenOnTime == null) {
        return null;
    } else {
        return secondsToString(screenOnTime);
    }
}

function getAverageScreenOnTime(date) {
    // Calculates the average screen on time for previous 7 days starting from parameter date
    date.setHours(0, 0, 0, 0);
    var totalScreenOnTime = 0;
    var numberOfDays = 0;
    var hours;
    var minutes;
    // Iterate over the previous 7 days
    for (var i = 0; i < 7; i++) {
        date.setDate(date.getDate() - 1);
        var screenOnTime = getScreenOnTime(date);
        // If screenOnTime is not null (meaning there is data for that day), accumulate total and increment days
        if (screenOnTime !== null) {
            var parts = screenOnTime.split(":");
            hours = parseInt(parts[0], 10);
            minutes = parseInt(parts[1], 10);
            screenOnTime = hours * 3600 + minutes * 60
            totalScreenOnTime += screenOnTime;
            numberOfDays++;
        }
    }
    var averageScreenOnTime = totalScreenOnTime / numberOfDays;
    return secondsToString(averageScreenOnTime);
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
