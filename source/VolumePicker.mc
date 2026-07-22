import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;

class VolumePicker extends WatchUi.View {

    var selectedVolume as Number = 1500;
    const MIN_VOLUME = 250;
    const MAX_VOLUME = 4000;
    const INCREMENT = 250;

    function initialize() {
        View.initialize();
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        var width = dc.getWidth();
        var height = dc.getHeight();
        var font = Graphics.FONT_TINY;
        var fontH = dc.getFontHeight(font);

        // Title
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(width / 2, height / 4, font, "Peak Volume (ml)", Graphics.TEXT_JUSTIFY_CENTER);

        // Volume value
        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
        dc.drawText(width / 2, height / 2 - fontH, Graphics.FONT_MEDIUM, selectedVolume.toString(), Graphics.TEXT_JUSTIFY_CENTER);

        // Instructions
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(width / 2, height * 3 / 4 - fontH, font, "UP/DOWN to change", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(width / 2, height * 3 / 4, font, "START to confirm", Graphics.TEXT_JUSTIFY_CENTER);
    }

    function increaseVolume() as Void {
        if (selectedVolume < MAX_VOLUME) {
            selectedVolume += INCREMENT;
            WatchUi.requestUpdate();
        }
    }

    function decreaseVolume() as Void {
        if (selectedVolume > MIN_VOLUME) {
            selectedVolume -= INCREMENT;
            WatchUi.requestUpdate();
        }
    }

}

class VolumePickerDelegate extends WatchUi.BehaviorDelegate {

    var parentView as spirometerView;
    var picker as VolumePicker;

    function initialize(parent as spirometerView, p as VolumePicker) {
        BehaviorDelegate.initialize();
        parentView = parent;
        picker = p;
    }

    function onSelect() as Boolean {
        // Confirm selection
        parentView.saveWithVolume(picker.selectedVolume);
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        return true;
    }

    function onNextPage() as Boolean {
        picker.decreaseVolume();
        return true;
    }

    function onPreviousPage() as Boolean {
        picker.increaseVolume();
        return true;
    }

    function onBack() as Boolean {
        // Discard without saving
        parentView.discardActivity();
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        return true;
    }

}
