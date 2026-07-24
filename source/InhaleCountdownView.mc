import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Timer;

class InhaleCountdownView extends WatchUi.View {

    var countdown as Number = Constants.INHALE_TIMEOUT;
    var timer as Timer.Timer?;

    function initialize() {
        View.initialize();
    }

    function onShow() as Void {
        timer = new Timer.Timer();
        timer.start(method(:onTick), 1000, true);
    }

    function onTick() as Void {
        countdown -= 1;
        if (countdown <= 0) {
            if (timer != null) {
                timer.stop();
                timer = null;
            }
            // Transition to hold-breath view
            WatchUi.switchToView(new HoldBreathView(), new HoldBreathDelegate(), WatchUi.SLIDE_LEFT);
        } else {
            WatchUi.requestUpdate();
        }
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        var width = dc.getWidth();
        var height = dc.getHeight();

        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
        dc.drawText(width / 2, height / 3, Graphics.FONT_MEDIUM, "Inhale", Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
        dc.drawText(width / 2, height / 2 + 10, Graphics.FONT_NUMBER_HOT, countdown.toString(), Graphics.TEXT_JUSTIFY_CENTER);
    }

    function onHide() as Void {
        if (timer != null) {
            timer.stop();
            timer = null;
        }
    }

}

class InhaleCountdownDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onBack() as Boolean {
        // Allow early dismissal
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        return true;
    }

}
