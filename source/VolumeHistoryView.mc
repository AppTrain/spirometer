import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;

class VolumeHistoryView extends WatchUi.View {

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
        dc.drawText(width / 2, 2, Graphics.FONT_TINY, "Daily Volume", Graphics.TEXT_JUSTIFY_CENTER);

        var chartTop = dc.getFontHeight(Graphics.FONT_TINY) + 16;
        var chartBottom = height - fontH - 20;
        var chartHeight = chartBottom - chartTop;
        var chartLeft = 40;
        var chartRight = width - 40;
        var barWidth = (chartRight - chartLeft) / 7;

        // Find max volume for scaling
        var maxVol = 500;
        for (var i = 0; i < summaries.size(); i++) {
            var entry = summaries[i] as Dictionary;
            var vol = entry["maxVol"] as Number;
            if (vol > maxVol) {
                maxVol = vol;
            }
        }

        // Draw bars and labels
        for (var i = 0; i < summaries.size(); i++) {
            var entry = summaries[i] as Dictionary;
            var x = chartLeft + (i * barWidth);
            var vol = entry["maxVol"] as Number;
            var sessions = entry["sessions"] as Number;
            var dayLabel = entry["day"] as String;

            // Bar
            if (sessions > 0 && vol > 0) {
                var barHeight = (vol * chartHeight) / maxVol;
                if (barHeight < 2) { barHeight = 2; }
                dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
                dc.fillRectangle(x + 2, chartBottom - barHeight, barWidth - 4, barHeight);

                // Volume label inside bar
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                dc.drawText(x + barWidth / 2, chartBottom - barHeight / 2 - fontH / 2, font,
                    vol.toString(), Graphics.TEXT_JUSTIFY_CENTER);
            }

            // Day label at bottom
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(x + barWidth / 2, chartBottom + 2, font, dayLabel, Graphics.TEXT_JUSTIFY_CENTER);
        }
    }

}

class VolumeHistoryDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onBack() as Boolean {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        return true;
    }

    function onNextPage() as Boolean {
        WatchUi.pushView(new HistoryView(), new HistoryDelegate(), WatchUi.SLIDE_UP);
        return true;
    }

    function onSelect() as Boolean {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        return true;
    }

}
