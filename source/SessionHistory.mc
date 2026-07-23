import Toybox.Application.Storage;
import Toybox.Lang;
import Toybox.Time;
import Toybox.Time.Gregorian;

module SessionHistory {

    const HISTORY_KEY = "session_history";

    // Save a session summary. Multiple sessions per day are stored.
    // Format per entry: { "ts" => unixTimestamp, "vol" => peakVolume, "breaths" => count, "avg" => avgTime }
    function saveSession(volume as Number, lapTimes as Array<Float>) as Void {
        var history = getHistory();

        var avg = 0.0;
        if (lapTimes.size() > 0) {
            var total = 0.0;
            for (var i = 0; i < lapTimes.size(); i++) {
                total += lapTimes[i];
            }
            avg = total / lapTimes.size();
        }

        var entry = {
            "ts" => Time.now().value(),
            "vol" => volume,
            "breaths" => lapTimes.size(),
            "avg" => avg
        };

        history.add(entry);

        // Prune entries older than 7 days
        var cutoff = Time.now().value() - (Constants.MAX_DAYS * Constants.SECONDS_PER_DAY);
        var pruned = [] as Array;
        for (var i = 0; i < history.size(); i++) {
            if ((history[i] as Dictionary)["ts"] >= cutoff) {
                pruned.add(history[i]);
            }
        }

        Storage.setValue(HISTORY_KEY, pruned);
    }

    function getHistory() as Array {
        var data = Storage.getValue(HISTORY_KEY);
        if (data == null) {
            return [] as Array;
        }
        return data as Array;
    }

    // Get daily summaries for the last 7 days
    // Returns array of { "day" => dayString, "sessions" => count, "totalBreaths" => n, "avgVol" => ml, "avgTime" => s }
    function getDailySummaries() as Array {
        var history = getHistory();
        var now = Time.now();
        var summaries = [] as Array;

        // Get today's local midnight
        var todayStart = Time.today().value();

        for (var d = 6; d >= 0; d--) {
            var dayStart = todayStart - (d * Constants.SECONDS_PER_DAY);
            var dayEnd = dayStart + Constants.SECONDS_PER_DAY;

            var sessions = 0;
            var totalBreaths = 0;
            var totalVol = 0;
            var totalAvgTime = 0.0;
            var dayMaxVol = 0;

            for (var i = 0; i < history.size(); i++) {
                var entry = history[i] as Dictionary;
                var ts = entry["ts"] as Number;
                if (ts >= dayStart && ts < dayEnd) {
                    sessions++;
                    totalBreaths += entry["breaths"] as Number;
                    totalVol += entry["vol"] as Number;
                    totalAvgTime += entry["avg"] as Float;
                    var vol = entry["vol"] as Number;
                    if (vol > dayMaxVol) {
                        dayMaxVol = vol;
                    }
                }
            }

            var info = Gregorian.info(new Time.Moment(dayStart), Time.FORMAT_SHORT);
            var dayLabel = info.day.toString();

            summaries.add({
                "day" => dayLabel,
                "sessions" => sessions,
                "totalBreaths" => totalBreaths,
                "avgVol" => (sessions > 0) ? (totalVol / sessions) : 0,
                "maxVol" => dayMaxVol,
                "avgTime" => (sessions > 0) ? (totalAvgTime / sessions) : 0.0
            });
        }

        return summaries;
    }

}
