import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Application;

class VolumePicker extends WatchUi.View {

    var selectedVolume as Number = Constants.DEFAULT_VOLUME;

    function initialize() {
        View.initialize();
        var saved = Application.Storage.getValue("lastVolume");
        if (saved != null) {
            selectedVolume = saved as Number;
        }
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        var width = dc.getWidth();
        var height = dc.getHeight();
        var font = Graphics.FONT_TINY;
        var fontH = dc.getFontHeight(font);
        var y = 5;

        // Logo
        var bmp = WatchUi.loadResource(Rez.Drawables.SpiroIcon);
        dc.drawBitmap(width / 2 - 30, y, bmp);
        y += 64;

        // Title
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(width / 2, y, font, "Volume Target (ml)", Graphics.TEXT_JUSTIFY_CENTER);
        y += fontH + 4;

        // Volume value
        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
        dc.drawText(width / 2, y, Graphics.FONT_MEDIUM, selectedVolume.toString(), Graphics.TEXT_JUSTIFY_CENTER);

        // Instructions
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(width / 2, height * 3 / 4 - fontH, font, "UP/DOWN to change", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(width / 2, height * 3 / 4, font, "START to begin", Graphics.TEXT_JUSTIFY_CENTER);
    }

    function increaseVolume() as Void {
        if (selectedVolume < Constants.MAX_VOLUME) {
            selectedVolume += Constants.INCREMENT;
            WatchUi.requestUpdate();
        }
    }

    function decreaseVolume() as Void {
        if (selectedVolume > Constants.MIN_VOLUME) {
            selectedVolume -= Constants.INCREMENT;
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
        // Confirm selection and remember volume for next time
        Application.Storage.setValue("lastVolume", picker.selectedVolume);
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
