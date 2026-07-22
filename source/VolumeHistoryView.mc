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
        var stepX = (chartRight - chartLeft) / 6; // 7 points, 6 gaps

        // Fixed scale: 0 to max volume
        var maxVol = Constants.MAX_VOLUME;

        // Draw Y axis
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(chartLeft, chartTop, chartLeft, chartBottom);
        // Draw X axis
        dc.drawLine(chartLeft, chartBottom, chartRight, chartBottom);

        // Y axis labels (litres)
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        var fourL = chartBottom - ((4000 * chartHeight) / maxVol);
        dc.drawText(chartLeft - 2, fourL - fontH / 2, font, "4L", Graphics.TEXT_JUSTIFY_RIGHT);
        dc.drawText(chartLeft - 2, chartTop + chartHeight / 2 - fontH / 2, font, "2L", Graphics.TEXT_JUSTIFY_RIGHT);
        dc.drawText(chartLeft - 2, chartBottom - fontH, font, "0", Graphics.TEXT_JUSTIFY_RIGHT);

        // Plot dots and connecting lines
        var prevX = 0;
        var prevY = 0;
        var hasPrev = false;

        for (var i = 0; i < summaries.size(); i++) {
            var entry = summaries[i] as Dictionary;
            var px = chartLeft + (i * stepX);
            var vol = entry["maxVol"] as Number;
            var sessions = entry["sessions"] as Number;
            var dayLabel = entry["day"] as String;

            // X axis date label
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(px, chartBottom + 2, font, dayLabel, Graphics.TEXT_JUSTIFY_CENTER);

            if (sessions > 0 && vol > 0) {
                var py = chartBottom - ((vol * chartHeight) / maxVol);

                // Connect to previous point
                if (hasPrev) {
                    dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
                    dc.drawLine(prevX, prevY, px, py);
                }

                // Draw dot
                dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
                dc.fillCircle(px, py, 4);

                // Volume label above dot (in litres)
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                var volL = (vol / 1000.0).format("%.1f");
                dc.drawText(px, py - fontH - 2, font, volL, Graphics.TEXT_JUSTIFY_CENTER);

                prevX = px;
                prevY = py;
                hasPrev = true;
            }
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
