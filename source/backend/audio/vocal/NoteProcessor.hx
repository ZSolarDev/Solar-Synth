package backend.audio.vocal;

import backend.song.Note;
import backend.song.SSProject.SSSection;
import backend.song.Voicebank;
import backend.utils.CopyUtil;
import backend.utils.VocalUtil;

class NoteProcessor
{
	public static function processNotes(notes:Array<Note>, voiceBank:Voicebank, autoTone:Bool):Array<Note>
	{
		var newNotes:Array<Note> = CopyUtil.copyArray(notes);
		for (noteID in 0...newNotes.length)
		{
			var note:Note = newNotes[noteID];
			var prevNote:Note = newNotes[noteID - 1];
			var nextNote:Note = newNotes[noteID + 1];
			// The breath is meant to be atonal, but there is still *sometimes* a tone. Turning up the breathiness param will make it minimal.
			if (VocalUtil.isBreath(note.phoneme))
			{
				note.atonal = true;
				for (pitch in note.pitches) // just in case
					pitch.value = 0;
			}

			if (nextNote != null)
			{
				var consonantCompensation = cast voiceBank.sampleStart - voiceBank.consonantSampleStart;
				if (!VocalUtil.isVowel(nextNote.phoneme)) // make sure the voiced part of the note starts where It's expected to start
				{
					note.duration -= consonantCompensation;
					nextNote.time -= consonantCompensation;
					nextNote.duration += consonantCompensation;
				}
			}
		}
		return newNotes;
	}

	public static function synthesizeVocalsFromNotes(notes:Array<Note>, voiceBank:Voicebank, autoTune:Bool = false, esperMode:Bool = false)
		return VocalSynthesizer.synthesizeVocals(processNotes(notes, voiceBank, autoTune), voiceBank, esperMode);
}
