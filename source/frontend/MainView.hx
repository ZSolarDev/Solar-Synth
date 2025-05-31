package frontend;

import openfl.media.SoundChannel;
import haxe.ui.notifications.NotificationManager;
import backend.data.Note;
import backend.data.Voicebank;
import backend.utils.VBLoader;
import backend.audio.vocal.NoteProcessor;
import backend.audio.vocal.VocalSynthesizer;
import haxe.ui.containers.VBox;
import haxe.ui.events.MouseEvent;

@:build(haxe.ui.ComponentBuilder.build("ui/main-view.xml"))
class MainView extends VBox {
    var notes:Array<Note> = [];
    var voicebank:Voicebank;
	var playbackChannel:SoundChannel;
	var storedMusicPosition:Float = 0.0;

    public function new() {
		super();

        voicebank = VBLoader.loadVoicebankFromFolder("voicebanks/Kasane Teto Lite");
		vb_listview.dataSource.add({
			text: voicebank.name,
		});
		notes.push(new Note("a", 0, 2000, true, 0, false, 0, 0, 0, 0, [{time: 0, value: 0}], [{time: 0, value: 1}], [{time: 0, value: 0}],
			[{time: 0, value: 0}], [{time: 0, value: 0}]));
		notes.push(new Note("o", 2000, 1000, true, 0, false, 0, 0, 0, 0, [{time: 0, value: 0}], [{time: 0, value: 1}], [{time: 0, value: 0}],
			[{time: 0, value: 1}], [{time: 0, value: 0}]));
		notes.push(new Note("b3", 3000, 3000, true, 0, false, 0, 0, 0, 0, [{time: 0, value: 0}], [{time: 0, value: 1}], [{time: 0, value: 0}],
			[{time: 0, value: 1}], [{time: 0, value: 0}]));
		notes.push(new Note("ka", 6000, 700, true, 0, false, 0, 0, 0, 0, [{time: 0, value: 0}], [{time: 0, value: 1}], [{time: 0, value: 0}],
			[{time: 0, value: 1}], []));
		notes.push(new Note("ki", 6700, 700, true, 0, false, 0, 0, 0, 0, [{time: 0, value: 1}], [{time: 0, value: 1}], [{time: 0, value: 0}],
			[{time: 0, value: 1}], [{time: 0, value: 0}]));
		notes.push(new Note("ru", 7400, 20000, true, 0, false, 0, 0, 0, 0, [{time: 0, value: -12}], [{time: 0, value: 1}], [{time: 0, value: 0}],
			[{time: 0, value: 1}], [{time: 0, value: 0}]));
    }
    
    @:bind(btn_synth, MouseEvent.CLICK)
    private function onSynthPressed(e:MouseEvent) {
		NotificationManager.instance.addNotification({
			type: Info,
			title: "Please wait!",
			body: "The vocals are in process, please wait!",
		});
        NoteProcessor.synthesizeVocalsFromNotes(notes, voicebank, false, false);
    }

	@:bind(btn_play, MouseEvent.CLICK)
    private function onPlayPressed(e:MouseEvent) {
        if (!VocalSynthesizer.synthesized) {
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
	private function onStopPressed(e:MouseEvent) {
		storedMusicPosition = playbackChannel.position;
		playbackChannel.stop();
	}
}