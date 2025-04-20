package frontend;

import backend.audio.vocal.NoteProcessor;
import backend.audio.vocal.VocalGenerator;
import backend.song.*;
import backend.utils.VBLoader;

class SongEditor extends FlxState
{
	public static var instance:SongEditor;

	public var project:SSProject;

	override public function new(project:SSProject)
	{
		super();
		this.project = project;
	}

	override public function create()
	{
		super.create();
		instance = this;
		initWindow();
		var voiceBank = VBLoader.loadVoicebankFromFolder('voicebanks/Kasane Teto Lite');

		var notes = project.tracks[0].sections[0].notes;
		notes.push(new Note("a", 0, 2000, 1213, 3936, false, [{time: 0, value: 0}], [{time: 0, value: 1}], [{time: 0, value: 0}], [{time: 0, value: 1}],
			[{time: 0, value: 0}]));
		notes.push(new Note("o", 2000, 1000, 1213, 3936, false, [{time: 0, value: 0}], [{time: 0, value: 1}], [{time: 0, value: 0}], [{time: 0, value: 1}],
			[{time: 0, value: 0}]));
		notes.push(new Note("b3", 3000, 3000, 1213, 3936, false, [{time: 0, value: 0}], [{time: 0, value: 1}], [{time: 0, value: 0}], [{time: 0, value: 1}],
			[{time: 0, value: 0}]));
		notes.push(new Note("ka", 6000, 700, 1213, 3936, false, [{time: 0, value: 0}], [{time: 0, value: 1}], [{time: 0, value: 0}], [{time: 0, value: 1}],
			[]));
		notes.push(new Note("na", 6700, 20000, 1213, 3936, false, [{time: 0, value: 0}], [{time: 0, value: 1}], [{time: 0, value: 0}], [{time: 0, value: 1}],
			[{time: 0, value: 0}]));

		var generator = NoteProcessor.generateVocalsFromNotes(notes, voiceBank);
		generator.sound.play();
	}

	function initWindow()
	{
		Main.window.focus();
		Main.window.width = 1280;
		Main.window.height = 720;
		Main.window.borderless = false;
		Main.window.resizable = true;
		Main.window.x = cast Main.window.display.bounds.width / 2 - (Main.window.width / 2);
		Main.window.y = cast Main.window.display.bounds.height / 2 - (Main.window.height / 2);
		FlxG.resizeGame(1280, 720);
		FlxG.scaleMode = new FixedScaleAdjustSizeScaleMode();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		FlxG.mouse.visible = true;
		if (FlxG.mouse.cursor != null)
			FlxG.mouse.cursor.bitmapData = FlxGraphic.fromAssetKey("_assets/cursor.png").bitmap;
	}
}
