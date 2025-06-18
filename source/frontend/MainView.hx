package frontend;

import backend.audio.formavox.FormaVox;
import backend.audio.kenetix.Kenetix;
import backend.data.Note;
import backend.data.SSProject;
import backend.data.Voicebank;
import backend.utils.NoteProcessorUtil;
import backend.utils.VoicebankUtil;
import haxe.ui.containers.VBox;
import haxe.ui.events.MouseEvent;
import haxe.ui.notifications.NotificationManager;
import openfl.media.SoundChannel;

@:build(haxe.ui.ComponentBuilder.build("themes/default/main-view.xml"))
class MainView extends VBox
{
	var notes:Array<Note> = [];
	var voicebank:Voicebank;
	var playbackChannel:SoundChannel;
	var project:SSProject;

	public function new()
	{
		super();
		initializeProject();
		initalizeTracks();
	}

	function initializeProject()
	{
		voicebank = VoicebankUtil.loadVoicebankFromFolder("voicebanks/Kasane Teto Lite");
		project = {
			name: 'Untitled',
			tracks: [
				{
					name: 'Track 1',
					voicebank: '',
					sections: [],
					muted: false,
					volume: 1,
					type: 'v',
					pan: 0,
					track: null
				},
				{
					name: 'Track wowie 2 ee',
					voicebank: '',
					sections: [],
					muted: true,
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
		notes.push(new Note("a", 0, 2000, 0, true, 0, false, 0, 0, 0, 0, [{time: 0, value: 0}], [{time: 0, value: 1}], [{time: 0, value: 0}],
			[{time: 0, value: 1}], [{time: 0, profile: FormaVox.getProfile('a')}]));
		notes.push(new Note("o", 2000, 1000, 0, true, 0, false, 0, 0, 0, 0, [{time: 0, value: 0}], [{time: 0, value: 1}], [{time: 0, value: 0}],
			[{time: 0, value: 1}], [{time: 0, profile: FormaVox.getProfile('o')}]));
		notes.push(new Note("u", 3000, 3000, 0, true, 0, false, 0, 0, 0, 0, [{time: 0, value: 0}], [{time: 0, value: 1}], [{time: 0, value: 0}],
			[{time: 0, value: 1}], [{time: 0, profile: FormaVox.getProfile('u')}]));
		notes.push(new Note("ka", 6000, 700, 0, true, 0, false, 0, 0, 0, 0, [{time: 0, value: 0}], [{time: 0, value: 1}], [{time: 0, value: 0}],
			[{time: 0, value: 1}], [{time: 0, profile: FormaVox.getProfile('ka')}]));
		notes.push(new Note("ki", 6700, 700, 0, true, 0, false, 0, 0, 0, 0, [{time: 0, value: 1}], [{time: 0, value: 1}], [{time: 0, value: 0}],
			[{time: 0, value: 1}], [{time: 0, profile: FormaVox.getProfile('ki')}]));
		notes.push(new Note("ru", 7400, 20000, 0, true, 0, false, 0, 0, 0, 0, [{time: 0, value: 2}], [{time: 0, value: 1}], [{time: 0, value: 0}],
			[{time: 0, value: 1}], [{time: 0, profile: FormaVox.getProfile('ru')}]));
	}

	function initalizeTracks()
	{
		for (track in project.tracks)
		{
			track.track = new Track(track);
			tracks_scrollview.addComponent(track.track.frame);
		}
	}

	@:bind(btn_synth, MouseEvent.CLICK)
	private function onSynthPressed(e:MouseEvent)
	{
		NotificationManager.instance.addNotification({
			type: Info,
			title: "Please wait!",
			body: "The vocals are in process, please wait!",
		});
		NoteProcessorUtil.synthesizeVocalsFromNotes(notes, voicebank, false, false);
	}

	@:bind(btn_play, MouseEvent.CLICK)
	private function onPlayPressed(e:MouseEvent)
	{
		if (!Kenetix.synthesized)
		{
			NotificationManager.instance.addNotification({
				type: Error,
				title: "Please wait!",
				body: "The vocals have not been synthesized yet, please wait!",
			});
			return;
		}

		playbackChannel = Kenetix.sound.play();
	}

	@:bind(btn_stop, MouseEvent.CLICK)
	private function onStopPressed(e:MouseEvent)
	{
		if (playbackChannel != null)
			playbackChannel.stop();
	}
}
