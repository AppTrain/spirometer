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
        dc.drawText(width / 2, 2, Graphics.FONT_TINY, "Progress", Graphics.TEXT_JUSTIFY_CENTER);

        // Calculate weekly totals for key
        var weekMaxVol = 0;
        var weekMaxBreaths = 0;
        for (var k = 0; k < summaries.size(); k++) {
            var s = summaries[k] as Dictionary;
            var mv = s["maxVol"] as Number;
            var tb = s["totalBreaths"] as Number;
            if (mv > weekMaxVol) { weekMaxVol = mv; }
            if (tb > weekMaxBreaths) { weekMaxBreaths = tb; }
        }

        // Key line
        var keyY = dc.getFontHeight(Graphics.FONT_TINY) + 2;
        var volStr = (weekMaxVol / 1000.0).format("%.1f");
        // "Best: " in white, volume in green, " / " in white, breaths in yellow
        var bestPrefix = "PR: ";
        var volPart = volStr + "L";
        var sep = " / ";
        var breathPart = weekMaxBreaths.toString() + " huffs";
        var totalStr = bestPrefix + volPart + sep + breathPart;
        var totalW = dc.getTextWidthInPixels(totalStr, font);
        var startX = (width - totalW) / 2;
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(startX, keyY, font, bestPrefix, Graphics.TEXT_JUSTIFY_LEFT);
        startX += dc.getTextWidthInPixels(bestPrefix, font);
        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
        dc.drawText(startX, keyY, font, volPart, Graphics.TEXT_JUSTIFY_LEFT);
        startX += dc.getTextWidthInPixels(volPart, font);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(startX, keyY, font, sep, Graphics.TEXT_JUSTIFY_LEFT);
        startX += dc.getTextWidthInPixels(sep, font);
        dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
        dc.drawText(startX, keyY, font, breathPart, Graphics.TEXT_JUSTIFY_LEFT);

        var chartTop = keyY + fontH + 4;
        var chartBottom = height - fontH - 20;
        var chartHeight = chartBottom - chartTop;
        var chartLeft = 40;
        var chartRight = width - 40;
        var barWidth = (chartRight - chartLeft) / 7;

        // Max volume scale
        var volScale = Constants.MAX_VOLUME;

        // Draw Y axis
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(chartLeft, chartTop, chartLeft, chartBottom);
        // Draw X axis
        dc.drawLine(chartLeft, chartBottom, chartRight, chartBottom);

        // Y axis labels (volume in litres)
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        var fourL = chartBottom - ((4000 * chartHeight) / Constants.MAX_VOLUME);
        dc.drawText(chartLeft - 2, fourL - fontH / 2, font, "4L", Graphics.TEXT_JUSTIFY_RIGHT);
        dc.drawText(chartLeft - 2, chartTop + chartHeight / 2 - fontH / 2, font, "2L", Graphics.TEXT_JUSTIFY_RIGHT);
        dc.drawText(chartLeft - 2, chartBottom - fontH, font, "0", Graphics.TEXT_JUSTIFY_RIGHT);

        // Draw bars and labels
        for (var i = 0; i < summaries.size(); i++) {
            var entry = summaries[i] as Dictionary;
            var x = chartLeft + (i * barWidth);
            var sessions = entry["sessions"] as Number;
            var breaths = entry["totalBreaths"] as Number;
            var maxVol = entry["maxVol"] as Number;
            var dayLabel = entry["day"] as String;

            // Bar - height based on peak volume, striped for multi-session days
            if (sessions > 0 && maxVol > 0) {
                var barHeight = (maxVol * chartHeight) / volScale;
                if (barHeight < 2) { barHeight = 2; }
                var barX = x + 2;
                var barW = barWidth - 4;
                var barTop = chartBottom - barHeight;

                if (sessions == 1) {
                    dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
                    dc.fillRectangle(barX, barTop, barW, barHeight);
                } else {
                    // Draw alternating stripes, one per session
                    var stripeHeight = barHeight / sessions;
                    if (stripeHeight < 2) { stripeHeight = 2; }
                    for (var s = 0; s < sessions; s++) {
                        var sy = chartBottom - ((s + 1) * stripeHeight);
                        if (s % 2 == 0) {
                            dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
                        } else {
                            dc.setColor(Graphics.COLOR_DK_BLUE, Graphics.COLOR_TRANSPARENT);
                        }
                        dc.fillRectangle(barX, sy, barW, stripeHeight);
                    }
                }

                // Breath count inside bar
                dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
                dc.drawText(x + barWidth / 2, chartBottom - barHeight / 2 - fontH / 2, font,
                    breaths.toString(), Graphics.TEXT_JUSTIFY_CENTER);

                // Peak volume in litres above bar
                if (maxVol > 0) {
                    var volL = (maxVol / 1000.0).format("%.1f");
                    dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
                    dc.drawText(x + barWidth / 2, barTop - fontH, font,
                        volL, Graphics.TEXT_JUSTIFY_CENTER);
                }
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
