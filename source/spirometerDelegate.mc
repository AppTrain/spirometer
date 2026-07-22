import Toybox.Lang;
import Toybox.WatchUi;

class spirometerDelegate extends WatchUi.BehaviorDelegate {

    var view as spirometerView;

    function initialize(v as spirometerView) {
        BehaviorDelegate.initialize();
        view = v;
    }

    // Start button starts or stops the activity
    function onSelect() as Boolean {
        if (view.state == spirometerView.STATE_READY) {
            view.startActivity();
        } else if (view.state == spirometerView.STATE_RUNNING) {
            view.stopActivity();
        }
        return true;
    }

    // Bottom-right (lap/back) adds a lap during activity
    function onBack() as Boolean {
        if (view.state == spirometerView.STATE_RUNNING) {
            view.addLap();
            return true;
        }
        return false;
    }

    // Down button shows history when not in an activity
    function onNextPage() as Boolean {
        if (view.state != spirometerView.STATE_RUNNING) {
            WatchUi.pushView(new VolumeHistoryView(), new VolumeHistoryDelegate(), WatchUi.SLIDE_UP);
            return true;
        }
        return false;
    }

}