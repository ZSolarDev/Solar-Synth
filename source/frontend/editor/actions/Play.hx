package frontend.editor.actions;

import backend.audio.vocal.NoteProcessor;
import backend.audio.vocal.VocalSynthesizer;
import backend.utils.CopyUtil;
import openfl.media.Sound;

class Play implements IAction
{
	public var complete:Bool = false;
	public var res:Dynamic;
	public var editor:SongEditor;
	public var running:Bool;

	public function new() {}

	public function startExecute(?data:Dynamic)
	{
		try
		{
			editor = SongEditor.instance;
			if (editor.sound == null)
				editor.sound = new Sound();
			NoteProcessor.synthesizeVocalsFromNotes(data, editor.voiceBank);
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
			if (VocalSynthesizer.synthesized)
			{
				editor.sound = VocalSynthesizer.sound;
				VocalSynthesizer.synthesized = false;
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
			complete = true;
		}
		catch (e)
			throw 'Error ending PLAY action:\n${e.details()}';
	}
}
