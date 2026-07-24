import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Timer;
import Toybox.ActivityRecording;
import Toybox.Activity;
import Toybox.FitContributor;
import Toybox.Attention;

class spirometerView extends WatchUi.View {

    enum {
        STATE_READY,
        STATE_RUNNING,
        STATE_STOPPED
    }

    var state as Number = STATE_READY;
    var session as ActivityRecording.Session?;
    var startTime as Number = 0;
    var elapsedSeconds as Float = 0.0;
    var lapTimes as Array<Float> = [];
    var lapActive as Boolean = false;
    var lapStartTime as Number = 0;
    var currentLapElapsed as Float = 0.0;
    var updateTimer as Timer.Timer?;
    var breathDurationField as FitContributor.Field?;
    var avgBreathField as FitContributor.Field?;
    var peakVolumeField as FitContributor.Field?;

    var selectedVolume as Number = 0;

    function initialize() {
        View.initialize();
    }

    function onLayout(dc as Dc) as Void {
    }

    function onShow() as Void {
        updateTimer = new Timer.Timer();
        updateTimer.start(method(:onTick), 100, true);
        // Auto-show volume picker on first launch
        if (state == STATE_READY) {
            showVolumePicker();
        }
    }

    function onTick() as Void {
        if (state == STATE_RUNNING) {
            elapsedSeconds = (System.getTimer() - startTime) / 1000.0;
            if (lapActive) {
                currentLapElapsed = (System.getTimer() - lapStartTime) / 1000.0;
            }
        }
        WatchUi.requestUpdate();
    }

    function startActivity() as Void {
        // Show volume picker first, then start recording
        showVolumePicker();
    }

    function startRecordingWithVolume(volume as Number) as Void {
        selectedVolume = volume;
        session = ActivityRecording.createSession({
            :name => "Spirometer " + volume.toString(),
            :sport => Activity.SPORT_GENERIC,
            :subSport => Activity.SUB_SPORT_BREATHING
        });

        breathDurationField = session.createField("breath_duration", 0,
            FitContributor.DATA_TYPE_FLOAT,
            {:mesgType => FitContributor.MESG_TYPE_LAP, :units => "s"}
        );
        avgBreathField = session.createField("avg_breath_time", 1,
            FitContributor.DATA_TYPE_FLOAT,
            {:mesgType => FitContributor.MESG_TYPE_SESSION, :units => "s"}
        );
        peakVolumeField = session.createField("Peak Volume", 3,
            FitContributor.DATA_TYPE_UINT16,
            {:mesgType => FitContributor.MESG_TYPE_RECORD, :units => "ml"}
        );

        session.start();
        startTime = System.getTimer();
        state = STATE_RUNNING;
    }

    function stopActivity() as Void {
        // Complete any in-progress lap
        if (lapActive) {
            completeLap();
        }
        if (session != null) {
            // Write session-level metrics
            if (avgBreathField != null && lapTimes.size() > 0) {
                var total = 0.0;
                for (var i = 0; i < lapTimes.size(); i++) {
                    total += lapTimes[i];
                }
                avgBreathField.setData(total / lapTimes.size());
            }
            if (peakVolumeField != null) {
                peakVolumeField.setData(selectedVolume);
            }
            session.stop();
            session.save();
            session = null;
        }
        // Store session summary for history
        SessionHistory.saveSession(selectedVolume, lapTimes);
        state = STATE_STOPPED;
    }

    function showVolumePicker() as Void {
        var picker = new VolumePicker();
        var delegate = new VolumePickerDelegate(self, picker);
        WatchUi.pushView(picker, delegate, WatchUi.SLIDE_UP);
    }

    function saveWithVolume(volume as Number) as Void {
        // Called from volume picker - start the actual recording
        startRecordingWithVolume(volume);
    }

    function discardActivity() as Void {
        // Volume picker cancelled - don't start
    }

    function addLap() as Void {
        if (state != STATE_RUNNING) {
            return;
        }
        if (lapActive) {
            // Complete the previous lap
            completeLap();
        }
        // Start new inhale countdown
        lapActive = true;
        lapStartTime = System.getTimer();
        if (Attention has :playTone) {
            Attention.playTone(Attention.TONE_LAP);
        }
        var inhaleView = new InhaleCountdownView();
        var inhaleDelegate = new InhaleCountdownDelegate();
        WatchUi.pushView(inhaleView, inhaleDelegate, WatchUi.SLIDE_UP);
    }

    function completeLap() as Void {
        var lapDuration = (System.getTimer() - lapStartTime) / 1000.0;
        lapTimes.add(lapDuration);
        lapActive = false;
        currentLapElapsed = 0.0;
        if (breathDurationField != null) {
            breathDurationField.setData(lapDuration);
        }
        if (session != null) {
            session.addLap();
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

        // Title
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(width / 2, y, Graphics.FONT_SMALL, "Spirometer", Graphics.TEXT_JUSTIFY_CENTER);
        y += dc.getFontHeight(Graphics.FONT_SMALL) + 2;

        // Timer
        if (state == STATE_READY) {
            var bmp = WatchUi.loadResource(Rez.Drawables.SpiroIcon);
            dc.drawBitmap(width / 2 - 30, y, bmp);
            y += 64;
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(width / 2, y, font, "Press START when you", Graphics.TEXT_JUSTIFY_CENTER);
            y += fontH;
            dc.drawText(width / 2, y, font, "have your Spirometer ready", Graphics.TEXT_JUSTIFY_CENTER);
            y += fontH + 4;
            dc.drawText(width / 2, y, font, "DOWN for stats", Graphics.TEXT_JUSTIFY_CENTER);
        } else if (state == STATE_RUNNING && lapActive) {
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(width / 2, y, font, "Press LAP to start next inhale.", Graphics.TEXT_JUSTIFY_CENTER);
        } else if (state == STATE_RUNNING && lapTimes.size() == 0) {
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(width / 2, y, font, "Press LAP to start your", Graphics.TEXT_JUSTIFY_CENTER);
            y += fontH;
            dc.drawText(width / 2, y, font, "first inhale.", Graphics.TEXT_JUSTIFY_CENTER);
        } else if (state == STATE_RUNNING) {
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(width / 2, y, font, "Press LAP to inhale again.", Graphics.TEXT_JUSTIFY_CENTER);
        } else {
            dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
            dc.drawText(width / 2, y, font, "STOPPED", Graphics.TEXT_JUSTIFY_CENTER);
            y += fontH;
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(width / 2, y, font, "DOWN for stats", Graphics.TEXT_JUSTIFY_CENTER);
        }
        y += fontH + 4;

        // Lap list
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        var maxVisible = 6;
        var startIdx = 0;
        if (lapTimes.size() > maxVisible) {
            startIdx = lapTimes.size() - maxVisible;
        }
        for (var i = startIdx; i < lapTimes.size(); i++) {
            var line = "Lap " + (i + 1) + ": " + (lapTimes[i] as Float).format("%.1f") + "s";
            dc.drawText(10, y, font, line, Graphics.TEXT_JUSTIFY_LEFT);
            y += fontH;
        }

        // Running total for current lap in list
        if (lapActive) {
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            var currentLine = "Lap " + (lapTimes.size() + 1) + ": " + currentLapElapsed.format("%.1f") + "s";
            dc.drawText(10, y, font, currentLine, Graphics.TEXT_JUSTIFY_LEFT);
            y += fontH;
        }

        // Lap count at bottom
        var totalBreaths = lapTimes.size();
        if (lapActive) { totalBreaths += 1; }
        if (totalBreaths > 0) {
            var avgY = height - fontH - 5;
            dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
            var label = (totalBreaths == 1) ? " breath" : " breaths";
            dc.drawText(width / 2, avgY, font,
                totalBreaths + label,
                Graphics.TEXT_JUSTIFY_CENTER);
        }
    }

    function onHide() as Void {
        if (updateTimer != null) {
            updateTimer.stop();
            updateTimer = null;
        }
    }

}
