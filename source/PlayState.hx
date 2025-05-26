package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.display.waveform.FlxWaveform;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUIState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;

class PlayState extends FlxUIState
{
	var waveform:FlxWaveform;

	override public function create():Void
	{
		super.create();

		FlxG.autoPause = false;
		FlxG.sound.music = FlxG.sound.load("assets/beeper" + #if flash ".mp3" #else ".ogg" #end, 1.0, true);

		// NOTE: Due to a limitation, on HTML5 you have to play the audio source
		// before trying to make a waveform from it.
		// See: https://github.com/ACrazyTown/flixel-waveform/issues/8
		FlxG.sound.music.play(true);

		// Create a new FlxWaveform instance.
		waveform = new FlxWaveform(5, 50, FlxG.width, FlxG.height - 50);

		// Load data from the FlxSound so the waveform renderer can process it.
		waveform.loadDataFromFlxSound(FlxG.sound.music);
		waveform.waveformTime = 0;
		waveform.waveformDuration = 5000;
		waveform.waveformDrawMode = COMBINED;
		waveform.waveformColor = 0xFF002397;
		waveform.waveformBgColor = 0x00000000;
		waveform.waveformDrawRMS = true;
		waveform.waveformRMSColor = 0xFF006EFF;
		waveform.waveformDrawBaseline = true;
		waveform.waveformBarSize = 1;
		waveform.waveformBarPadding = 0;
		waveform.waveformChannelPadding = 0;
		add(waveform);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (FlxG.sound.music.playing)
			waveform.waveformTime = FlxG.sound.music.time;

		if (FlxG.keys.justPressed.SPACE)
			playPause();
	}

	override public function destroy():Void
	{
		super.destroy();
	}

	function playPause():Void
	{
		FlxG.sound.music.playing ? FlxG.sound.music.pause() : FlxG.sound.music.resume();
	}
}
