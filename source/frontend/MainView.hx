package frontend;

import backend.audio.vocal.NoteProcessor;
import backend.audio.vocal.VocalSynthesizer;
import backend.data.Note;
import backend.data.SSProject;
import backend.data.Voicebank;
import backend.utils.VoicebankUtil;
import frontend.itemrenderers.*;
import haxe.ui.containers.VBox;
import haxe.ui.events.MouseEvent;
import haxe.ui.notifications.NotificationManager;
import openfl.media.SoundChannel;

@:build(haxe.ui.ComponentBuilder.build("ui/main-view.xml"))
class MainView extends VBox
{
	var notes:Array<Note> = [];
	var voicebank:Voicebank;
	var playbackChannel:SoundChannel;
	var project:SSProject;

	public function new()
	{
		super();
		voicebank = VoicebankUtil.loadVoicebankFromFolder("voicebanks/Kasane Teto Lite");
		project = {
			name: 'Untitled',
			tracks: [
				{
					name: 'Track 1',
					voicebank: voicebank.name,
					sections: [],
					muted: false,
					volume: 1,
					type: 'v',
					pan: 0,
					track: null
				}
			],
			timeSignatureNumerator: 4,
			timeSignatureDenominator: 4,
			settings: {},
			bpm: [{time: 0, value: 120}]
		};
		project.tracks[0].track = new Track(project.tracks[0]);
		tracks_scrollview.addComponent(project.tracks[0].track.frame);
		notes.push(new Note("a", 0, 2000, 0, true, 0, false, 0, 0, 0, 0, [{time: 0, value: 0}], [{time: 0, value: 1}], [{time: 0, value: 0}],
			[{time: 0, value: 0}], [{time: 0, value: 0}]));
		notes.push(new Note("o", 2000, 1000, 0, true, 0, false, 0, 0, 0, 0, [{time: 0, value: 0}], [{time: 0, value: 1}], [{time: 0, value: 0}],
			[{time: 0, value: 1}], [{time: 0, value: 0}]));
		notes.push(new Note("b3", 3000, 3000, 0, true, 0, false, 0, 0, 0, 0, [{time: 0, value: 0}], [{time: 0, value: 1}], [{time: 0, value: 0}],
			[{time: 0, value: 1}], [{time: 0, value: 0}]));
		notes.push(new Note("ka", 6000, 700, 0, true, 0, false, 0, 0, 0, 0, [{time: 0, value: 0}], [{time: 0, value: 1}], [{time: 0, value: 0}],
			[{time: 0, value: 1}], []));
		notes.push(new Note("ki", 6700, 700, 0, true, 0, false, 0, 0, 0, 0, [{time: 0, value: 1}], [{time: 0, value: 1}], [{time: 0, value: 0}],
			[{time: 0, value: 1}], [{time: 0, value: 0}]));
		notes.push(new Note("ru", 7400, 20000, 0, true, 0, false, 0, 0, 0, 0, [{time: 0, value: -12}], [{time: 0, value: 1}], [{time: 0, value: 0}],
			[{time: 0, value: 1}], [{time: 0, value: 0}]));
	}

	@:bind(btn_synth, MouseEvent.CLICK)
	private function onSynthPressed(e:MouseEvent)
	{
		NotificationManager.instance.addNotification({
			type: Info,
			title: "Please wait!",
			body: "The vocals are in process, please wait!",
		});
		NoteProcessor.synthesizeVocalsFromNotes(notes, voicebank, false, false);
	}

	@:bind(btn_play, MouseEvent.CLICK)
	private function onPlayPressed(e:MouseEvent)
	{
		if (!VocalSynthesizer.synthesized)
		{
			NotificationManager.instance.addNotification({
				type: Error,
				title: "Please wait!",
				body: "The vocals have not been synthesized yet, please wait!",
			});
			return;
		}

		playbackChannel = VocalSynthesizer.sound.play();
	}

	@:bind(btn_stop, MouseEvent.CLICK)
	private function onStopPressed(e:MouseEvent)
	{
		if (playbackChannel != null)
			playbackChannel.stop();
	}
}
