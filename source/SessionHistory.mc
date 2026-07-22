import Toybox.Application.Storage;
import Toybox.Lang;
import Toybox.Time;
import Toybox.Time.Gregorian;

module SessionHistory {

    const HISTORY_KEY = "session_history";
    const MAX_DAYS = 7;

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
        var cutoff = Time.now().value() - (MAX_DAYS * 86400);
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

        for (var d = 6; d >= 0; d--) {
            var dayStart = now.value() - ((d + 1) * 86400);
            var dayEnd = now.value() - (d * 86400);

            var sessions = 0;
            var totalBreaths = 0;
            var totalVol = 0;
            var totalAvgTime = 0.0;

            for (var i = 0; i < history.size(); i++) {
                var entry = history[i] as Dictionary;
                var ts = entry["ts"] as Number;
                if (ts >= dayStart && ts < dayEnd) {
                    sessions++;
                    totalBreaths += entry["breaths"] as Number;
                    totalVol += entry["vol"] as Number;
                    totalAvgTime += entry["avg"] as Float;
                }
            }

            var info = Gregorian.info(new Time.Moment(dayEnd - 86400), Time.FORMAT_SHORT);
            var dayLabel = info.month.toString() + "/" + info.day.toString();

            summaries.add({
                "day" => dayLabel,
                "sessions" => sessions,
                "totalBreaths" => totalBreaths,
                "avgVol" => (sessions > 0) ? (totalVol / sessions) : 0,
                "avgTime" => (sessions > 0) ? (totalAvgTime / sessions) : 0.0
            });
        }

        return summaries;
    }

}
