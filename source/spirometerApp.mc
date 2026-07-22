import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class spirometerApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state as Dictionary?) as Void {
    }

    function onStop(state as Dictionary?) as Void {
    }

    function getInitialView() as [Views] or [Views, InputDelegates] {
        var view = new spirometerView();
        var delegate = new spirometerDelegate(view);
        return [view, delegate];
    }

}

function getApp() as spirometerApp {
    return Application.getApp() as spirometerApp;
}