var db = LocalStorage.openDatabaseSync("screenData.sqlite");

function initializeDatabase() {
    db.transaction(
        function(tx) {
            tx.executeSql('CREATE TABLE IF NOT EXISTS events(timestamp INT, powered INT)');
        }
    );
    // Check if the latest event is "on" when initializing DB
    // This means the app has not closed succesfully last time and we need to fix the DB
    var latestValues = getLatestEvent();
    if (latestValues[1] === 1) {
        console.log("App has not closed succesfully last time, removing the last entry");
        removeEvent(latestValues[0]);
    }
    insertEvent("on");
    console.log("Initialized database");
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

function getFirstEventOfDay(date) {
    var firstEventTimestamp;
    var firstEventPowered;
    db.transaction(
        function(tx) {
            var result = tx.executeSql('\
                SELECT timestamp, powered \
                FROM events \
                WHERE timestamp >= ? \
                AND timestamp < ? + 86400000 \
                ORDER BY timestamp ASC \
                LIMIT 1',
                [date.getTime(), date.getTime()]
            );
            if (result.rows.length > 0) {
                firstEventTimestamp = result.rows.item(0).timestamp;
                firstEventPowered = result.rows.item(0).powered;
            } else {
                firstEventTimestamp = "emptydb";
                firstEventPowered = "emptydb";
            }
        }
    );
    return [firstEventTimestamp, firstEventPowered];
}

function getLastEventForDay(date) {
    var lastEventTimestamp;
    var lastEventPowered;
    db.transaction(
        function(tx) {
            var result = tx.executeSql('\
                SELECT timestamp, powered \
                FROM events \
                WHERE timestamp >= ? \
                AND timestamp < ? + 86400000 \
                ORDER BY timestamp DESC \
                LIMIT 1',
                [date.getTime(), date.getTime()]
            );
            if (result.rows.length > 0) {
                lastEventTimestamp = result.rows.item(0).timestamp;
                lastEventPowered = result.rows.item(0).powered;
            } else {
                lastEventTimestamp = "emptydb";
                lastEventPowered = "emptydb";
            }
        }
    );
    return [lastEventTimestamp, lastEventPowered];
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
        // Cap session length to max todays length and add it to summed earlier sessions
        var now = new Date().getTime()
        var currSessionLength = Math.min((now-date.getTime()), (now-latestValues[0]));
        screenOnTime = screenOnTime + (currSessionLength / 1000);
    }
    // If the last event for day has been "on", and the day is not today,
    // we need to add duration from that untill midnight
    var lastEventForDay = getLastEventForDay(date);
    if (lastEventForDay[1] === 1 && date.getTime() !== new Date().setHours(0, 0, 0, 0)) {
        var midnight = date.getTime() + 86400000; // Next day midnight
        var durationUntilMidnight = midnight - lastEventForDay[0];
        screenOnTime = screenOnTime + (durationUntilMidnight / 1000);
    }
    // Add seconds from the start of the day to the first event of the day if the first event has been "off"
    var firstEventOfDay = getFirstEventOfDay(date);
    if (firstEventOfDay[1] === 0) {
        var startOfDayToFirstEvent = firstEventOfDay[0] - date.getTime();
        screenOnTime = screenOnTime + (startOfDayToFirstEvent / 1000);
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
    if (numberOfDays === 0) {
        return "Not enough data";
    } else {
        var averageScreenOnTime = totalScreenOnTime / numberOfDays;
        return secondsToString(averageScreenOnTime);
    }
}

function getData(date) {
    // Returns all data for specific date
    var data = [];
    var startOfDay = new Date(date);
    startOfDay.setHours(0, 0, 0, 0);
    var endOfDay = new Date(date);
    endOfDay.setHours(23, 59, 59, 999);

    db.transaction(
        function(tx) {
            var result = tx.executeSql('SELECT timestamp, powered FROM events WHERE timestamp >= ? AND timestamp <= ?',
                [startOfDay.getTime(), endOfDay.getTime()]);
            for (var i = 0; i < result.rows.length; i++) {
                var item = result.rows.item(i);
                // Convert milliseconds to seconds by dividing by 1000
                var timestampInSeconds = item.timestamp / 1000;
                var dataPoint = {
                    x: timestampInSeconds, // Use seconds
                    y: item.powered
                };
                data.push(dataPoint);
            }
        }
    );
    return data
}

function getPoweredEvents(date) {
    // Returns all screen on / off events to populate the screenEventGraph
    var startOfDay = new Date(date);
    startOfDay.setHours(0, 0, 0, 0);
    var dataPoint = {
        x: null,
        y: null
    };
    var data = getData(date);

    // If data length is 0, but graph data is requested for today we know that the screen has been on from startOfDay
    if (data.length === 0 && date.toDateString() === startOfDay.toDateString()) {
        dataPoint = {
            x: startOfDay.getTime() / 1000,
            y: 1
        };
        data.push(dataPoint);
    }
    if (data.length > 0) {
        // If the last event is screen on, add screen on event to now to extend the graph
        if (data[data.length - 1].y === 1) {
            dataPoint = {
                x: Date.now() / 1000,
                y: 1
            };
            data.push(dataPoint);
        }
        // If the first event of the day has been screen off, we need to add screen on to start of the day
        if (data[0].y === 0) {
            dataPoint = {
                x: startOfDay.getTime()/1000,
                y: 1
            };
            data.unshift(dataPoint); // Add to start of the array
        }
    }
    return data;
}

function getCumulativeUsage(date) {
    // Returns cumulative usage in minutes
    // TODO: Instead of using the getData function make a function which makes the SQL query to get all data for the day
    //  and use that in here and in getData. This allows us to handle the chart updating for the current session for
    // both charts. Now we cant add the current session in getData, because it would break the logic in here?
    // Should this even be used for calculating the screen time? We could get rid of the complex SQL query
    var data = getData(date);
    var cumulativeData = []
    var cumulativeScreenOnTime = 0;
    var lastTimestamp = null;
    var lastPoweredState = null;
    var dataPoint = {
        x: null,
        y: null
    };

    // If the first event of the day has been screen off, we need to add time from midnight up to that point
    var firstEventOfDay = getFirstEventOfDay(date);
    if (firstEventOfDay[1] === 0) {
        var startOfDay = new Date(date);
        startOfDay.setHours(0, 0, 0, 0);
        var startOfDayToFirstEvent = firstEventOfDay[0] - startOfDay.getTime();
        cumulativeScreenOnTime += (startOfDayToFirstEvent / 1000) / 60; // Minutes
        // Add to cumulative data
        dataPoint = {
            x: firstEventOfDay[0]/1000,
            y: cumulativeScreenOnTime
        };
        var midnightDataPoint = {
            x: startOfDay.getTime()/1000,
            y: 0
        };
        cumulativeData.push(midnightDataPoint);
        cumulativeData.push(dataPoint);
    }

    for (var i = 0; i < data.length; i++) {
        var timestamp = data[i].x;
        var poweredState = data[i].y;


        var duration = (timestamp - lastTimestamp);
        if (poweredState === 0) {
            cumulativeScreenOnTime += (duration/60); // Add duration to cumulative screen on time
        }

        lastTimestamp = timestamp;
        //lastPoweredState = poweredState;

        dataPoint = {
            x: timestamp,
            y: cumulativeScreenOnTime
        };
        cumulativeData.push(dataPoint);
    }

    // If last event is screen on, add remaining time until current time
    if (poweredState === 1) {
        var currentTimestamp = Date.now() / 1000;
        var remainingDuration = (currentTimestamp - lastTimestamp) / 60;
        cumulativeScreenOnTime += remainingDuration;
        dataPoint = {
            x: currentTimestamp,
            y: cumulativeScreenOnTime
        };
        cumulativeData.push(dataPoint);
    }

    return cumulativeData;
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

function removeEvent(timestamp) {
    db.transaction(
        function(tx) {
            tx.executeSql('DELETE FROM events WHERE timestamp = ?', [timestamp]);
        }
    );
}

function getDatabase() {
    return db;
}
