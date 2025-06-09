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
		frame = ComponentBuilder.fromString('
            <frame id="track" width="300" height="110">
                <hbox width="100%" height="auto">
                    <image id="vbIcon" width="80" height="80" />
                    <vbox width="100%" height="auto">
                        <!--WHY CANT I HORIZONTAL ALIGN A VBOX!?!?-->
                        <!--I had to make this stupid workaround instead...-->
                        <hbox width="200" height="20" horizontalAlign="right">
                            <button text="M" toggle="true" id="mute_btn" width="20" height="20"/>
                            <dropdown text="Select a Voicebank" id="voicebankDropdown" width="100%">
                            </dropdown>
                        </hbox>
                        <hbox width="200" height="20" horizontalAlign="right">
                            <button text="S" toggle="true" id="solo_btn" width="20" height="20"/>
                        </hbox>
                        <hbox width="200" height="40">
                            <vbox width="90" height="auto">
                                <label text="Volume: 100%" id="volText"/>
                                <slider pos="100" id="volume" height="10" width="90"/>
                            </vbox>
                            <vbox width="90" height="auto" style="margin-left:10px;">
                                <label text="Pan: 0%" id="panText" />
                                <slider pos="50" id="pan" center="50" height="10" width="90"/>
                            </vbox>
                        </hbox>
                    </vbox>
                </hbox>
            </frame>
        ');
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
