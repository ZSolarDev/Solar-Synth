package backend.utils;

import backend.audio.kenetix.Kenetix;
import backend.data.Note;
import backend.data.SongValue;
import backend.data.Voicebank;

class NoteProcessorUtil
{
	static function applyCurveMask(base:Array<SongValue>, modifier:Array<SongValue>):Array<SongValue>
	{
		var result:Array<SongValue> = [];

		for (i in 0...base.length)
		{
			var baseVal = base[i];
			var modVal = modifier[i];

			var maskedValue = baseVal.value * (modVal.value / 100);
			result.push({
				time: baseVal.time,
				value: maskedValue
			});
		}

		return result;
	}

	static function generateBreathCurve(length:Int, type:String):Array<SongValue>
	{
		var values:Array<SongValue> = [];
		if (type == "inhale")
		{
			for (time in 0...length)
			{
				var t = time / length;
				var intensity:Float;

				if (t < 0.3)
					intensity = (t / 0.3) * 60;
				else if (t < 0.7)
					intensity = 60 + ((t - 0.3) / 0.4) * 40;
				else
					intensity = 100 - ((t - 0.7) / 0.3) * 100;

				values.push({time: time, value: intensity});
			}
		}
		else
		{
			for (time in 0...length)
			{
				var t = time / length;
				var intensity:Float;
				if (t < 0.2)
					intensity = (t / 0.2) * 100;
				else
					intensity = 100 * (1 - ((t - 0.2) / 0.8));
				values.push({time: time, value: intensity});
			}
		}
		return values;
	}

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

			if (note.phoneme == "inhale" || note.phoneme == "exhale")
			{
				var ogBreathCurve = note.breathiness;
				var newBreathCurve = generateBreathCurve(note.duration, note.phoneme);
				var finalBreathCurve = applyCurveMask(newBreathCurve, ogBreathCurve);
				note.breathiness = finalBreathCurve;
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

				if (note.automaticBlendRatio)
				{
					// A longer blend
					if (VocalUtil.isBreath(nextNote.phoneme) || VocalUtil.isVowel(nextNote.phoneme))
						note.blendRatio = 500;
					// If the next note is a plosive, there will be a tiny pause before you hear the next note.
					if (VocalUtil.isPlosive(nextNote.phoneme) && !VocalUtil.isBreath(nextNote.phoneme))
						note.blendRatio = 10;
					// It will kinda blend, have to keep it short so you can still hear the consonant though
					if (VocalUtil.isContinuant(nextNote.phoneme))
						note.blendRatio = 50;
				}
			}
		}
		return newNotes;
	}

	public static function synthesizeVocalsFromNotes(notes:Array<Note>, voiceBank:Voicebank, autoTune:Bool = false, resampMode:Bool = false)
		return Kenetix.synthesizeVocals(processNotes(notes, voiceBank, autoTune), voiceBank, resampMode);
}
