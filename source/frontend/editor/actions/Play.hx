package frontend.editor.actions;

import backend.audio.vocal.NoteProcessor;
import backend.audio.vocal.VocalSynthesizer;
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
			NoteProcessor.synthesizeVocalsFromNotes(data.notes, editor.voiceBank, data.autoTune, data.resampMode);
			running = true;
			trace('Synthesizing...');
		}
		catch (e)
			throw 'Error stating Play action:\n${e.details()}';
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
			throw 'Error updating Play action:\n${e.details()}';
	}

	public function endExecute()
	{
		try
		{
			trace('Completed Play action');
			complete = true;
		}
		catch (e)
			throw 'Error ending Play action:\n${e.details()}';
	}
}
