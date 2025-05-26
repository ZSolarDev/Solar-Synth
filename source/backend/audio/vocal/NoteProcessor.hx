package backend.audio.vocal;

import backend.song.Note;
import backend.song.SSProject.SSSection;
import backend.song.Voicebank;
import backend.utils.CopyUtil;
import backend.utils.VocalUtil;

class NoteProcessor
{
	public static function processNotes(notes:Array<Note>, voiceBank:Voicebank):Array<Note>
	{
		var newNotes:Array<Note> = CopyUtil.copyArray(notes);
		for (note in newNotes)
		{
			// The breath is meant to be atonal, but there is still *sometimes* a tone. Turning up the breathiness param will make it minimal.
			if (VocalUtil.isBreath(note.phoneme))
				note.atonal = true;
		}
		return newNotes;
	}

	public static function synthesizeVocalsFromNotes(notes:Array<Note>, voiceBank:Voicebank, esperMode:Bool = false)
		return VocalSynthesizer.synthesizeVocals(processNotes(notes, voiceBank), voiceBank, esperMode);
}
