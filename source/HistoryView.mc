import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;

class HistoryView extends WatchUi.View {

    var summaries as Array = [];

    function initialize() {
        View.initialize();
        summaries = SessionHistory.getDailySummaries();
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        var width = dc.getWidth();
        var height = dc.getHeight();
        var font = Graphics.FONT_XTINY;
        var fontH = dc.getFontHeight(font);

        // Title
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(width / 2, 2, Graphics.FONT_TINY, "7-Day History", Graphics.TEXT_JUSTIFY_CENTER);

        var chartTop = dc.getFontHeight(Graphics.FONT_TINY) + 8;
        var chartBottom = height - fontH - 4;
        var chartHeight = chartBottom - chartTop;
        var barWidth = (width - 20) / 7;

        // Find max volume for scaling
        var maxVol = 500;
        for (var i = 0; i < summaries.size(); i++) {
            var entry = summaries[i] as Dictionary;
            var vol = entry["avgVol"] as Number;
            if (vol > maxVol) {
                maxVol = vol;
            }
        }

        // Draw bars and labels
        for (var i = 0; i < summaries.size(); i++) {
            var entry = summaries[i] as Dictionary;
            var x = 10 + (i * barWidth);
            var vol = entry["avgVol"] as Number;
            var sessions = entry["sessions"] as Number;
            var dayLabel = entry["day"] as String;

            // Bar
            if (sessions > 0) {
                var barHeight = (vol * chartHeight) / maxVol;
                if (barHeight < 2) { barHeight = 2; }
                dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
                dc.fillRectangle(x + 2, chartBottom - barHeight, barWidth - 4, barHeight);

                // Breath count on top of bar
                dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
                var breaths = entry["totalBreaths"] as Number;
                dc.drawText(x + barWidth / 2, chartBottom - barHeight - fontH, font,
                    breaths.toString(), Graphics.TEXT_JUSTIFY_CENTER);
            }

            // Day label at bottom
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(x + barWidth / 2, chartBottom + 2, font, dayLabel, Graphics.TEXT_JUSTIFY_CENTER);
        }
    }

}

class HistoryDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onBack() as Boolean {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        return true;
    }

    function onSelect() as Boolean {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        return true;
    }

}
