package frontend.editor.actions;

import backend.audio.vocal.NoteProcessor;
import backend.audio.vocal.VocalGenerator;
import backend.song.Note;
import openfl.media.Sound;

class Play implements IAction
{
	public var complete:Bool = false;
	public var res:Dynamic;
	public var editor:SongEditor;
	public var generator:VocalGenerator;
	public var running:Bool;

	public function new() {}

	public function startExecute(?data:Dynamic)
	{
		try
		{
			editor = SongEditor.instance;
			if (editor.sound == null)
				editor.sound = new Sound();
			generator = NoteProcessor.generateVocalsFromNotes(data, editor.voiceBank);
			running = true;
			trace('loading!');
		}
		catch (e)
			throw 'Error stating PLAY action:\n${e.details()}';
	}

	public function update(?data:Dynamic)
	{
		try
		{
			if (generator.sound != null)
			{
				editor.sound = generator.sound;
				FlxG.sound.play(editor.sound, 1);
				endExecute();
			}
		}
		catch (e)
			throw 'Error updating PLAY action:\n${e.details()}';
	}

	public function endExecute()
	{
		try
		{
			trace('COMPLETED!!!');
			generator = null;
			complete = true;
		}
		catch (e)
			throw 'Error ending PLAY action:\n${e.details()}';
	}
}
