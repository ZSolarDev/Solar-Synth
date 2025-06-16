package frontend;

import backend.data.SSProject.SSTrack;
import backend.utils.VoicebankUtil;
import haxe.ui.ComponentBuilder;
import haxe.ui.components.Button;
import haxe.ui.components.DropDown;
import haxe.ui.components.Image;
import haxe.ui.components.Label;
import haxe.ui.components.Slider;
import haxe.ui.containers.Frame;
import haxe.ui.data.ArrayDataSource;

class Track
{
	public var frame:Frame;
	public var track:SSTrack;

	public function new(track:SSTrack)
	{
		this.track = track;
		frame = ComponentBuilder.fromFile('themes/default/objects/track.xml');
		frame.text = track.name;
		updateDropdown();
		var pan = frame.findComponent("pan", Slider);
		var panText = frame.findComponent("panText", Label);
		var volume = frame.findComponent("volume", Slider);
		var volText = frame.findComponent("volText", Label);
		pan.onChange = (_) ->
		{
			panText.text = 'Pan: ${Math.round(pan.value) * 2 - 100}%';
			track.pan = pan.value;
		}
		volume.onChange = (_) ->
		{
			volText.text = 'Volume: ${Math.round(volume.value)}%';
			track.volume = volume.value;
		}
		var mute = frame.findComponent("mute_btn", Button);
		track.muted = mute.selected;
	}

	public function updateDropdown()
	{
		var dropdown = frame.findComponent("voicebankDropdown", DropDown);
		var curSelected = dropdown.selectedItem;

		var ds:ArrayDataSource<String> = new ArrayDataSource<String>();
		dropdown.dataSource = ds;

		for (voicebank in VoicebankUtil.getVoicebanks())
			ds.add(voicebank.name);

		var index = ds.indexOf(curSelected);
		if (index != -1)
			dropdown.selectedIndex = index;
		else
			dropdown.text = "Select a Voicebank";

		if (ds.size == 0)
			dropdown.text = "No Voicebanks";

		dropdown.onChange = (_) ->
		{
			frame.findComponent("vbIcon", Image).resource = 'voicebanks/${dropdown.selectedItem}/icon.png';
			track.voicebank = dropdown.selectedItem;
		}
	}
}
