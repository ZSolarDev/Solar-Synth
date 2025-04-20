package frontend.editor;

import backend.audio.vocal.NoteProcessor;
import backend.song.*;
import backend.utils.SSProjectUtil;
import backend.utils.VBLoader;
import haxe.Json;
import sys.io.File;

class SongEditor extends FlxState
{
	public static var instance:SongEditor;

	public var project:SSProject;
	public var voiceBank:Voicebank;

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
		voiceBank = VBLoader.loadVoicebankFromFolder('voicebanks/${project.voicebank}');
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
		updateInput();
	}

	function updateInput()
	{
		if (FlxG.keys.justPressed.SPACE)
		{
			project.tracks[0] = {
				name: 'Track 0',
				sections: [
					{
						name: 'Vocals',
						time: 0,
						type: 'v', // v for vocal
						soundPath: '',
						notes: [],
						duration: 50000,
						bpm: 120
					},
					{
						name: 'Instrumental',
						time: 0,
						type: 'a', // a for audio
						soundPath: '',
						notes: [],
						duration: 50000,
						bpm: 120
					}
				],
				muted: false,
				volume: 1
			}
			var notes = project.tracks[0].sections[0].notes;
			notes.push(new Note("a", 0, 2000, 1213, 3936, false, [{time: 0, value: 0}], [{time: 0, value: 1}], [{time: 0, value: 0}], [{time: 0, value: 1}],
				[{time: 0, value: 0}]));
			notes.push(new Note("o", 2000, 1000, 1213, 3936, false, [{time: 0, value: 0}], [{time: 0, value: 1}], [{time: 0, value: 0}],
				[{time: 0, value: 1}], [{time: 0, value: 0}]));
			notes.push(new Note("b3", 3000, 3000, 1213, 3936, false, [{time: 0, value: 0}], [{time: 0, value: 1}], [{time: 0, value: 0}],
				[{time: 0, value: 1}], [{time: 0, value: 0}]));
			notes.push(new Note("ka", 6000, 700, 1213, 3936, false, [{time: 0, value: 0}], [{time: 0, value: 1}], [{time: 0, value: 0}],
				[{time: 0, value: 1}], []));
			notes.push(new Note("na", 6700, 20000, 1213, 3936, false, [{time: 0, value: 0}], [{time: 0, value: 1}], [{time: 0, value: 0}],
				[{time: 0, value: 1}], [{time: 0, value: 0}]));

			var proj = SSProjectUtil.projectToTypedef(project);
			inline function validateName(str:String):String
			{
				var res:String = str;
				res.replace('/', '');
				res.replace('\\', '');
				res.replace(':', '');
				res.replace('*', '');
				res.replace('?', '');
				res.replace('"', '');
				res.replace('<', '');
				res.replace('?', '');
				res.replace('|', '');
				return res;
			}
			File.saveContent(validateName(project.name) + '.ssp', Json.stringify(proj, null, '    '));
			var generator = NoteProcessor.generateVocalsFromNotes(notes, voiceBank);
			generator.sound.play();
		}
		if (FlxG.keys.justPressed.P)
		{
			var generators = NoteProcessor.generateVocalsFromSections(project.tracks[0].sections, voiceBank);
			for (generator in generators)
				generator.sound.play();
		}
	}
}
