package backend.audio.vocal;

import backend.song.Note;
import backend.song.SSProject.SSSection;
import backend.song.Voicebank;
import backend.utils.CopyUtil;

class NoteProcessor
{
	public static function processNotes(notes:Array<Note>, voiceBank:Voicebank):Array<Note>
	{
		var newNotes:Array<Note> = CopyUtil.copyArray(notes);
		return newNotes;
	}

	public static function generateVocalsFromNotes(notes:Array<Note>, voiceBank:Voicebank):VocalGenerator
	{
		var vocals = new VocalGenerator(processNotes(notes, voiceBank), voiceBank);
		vocals.generateVocals();
		return vocals;
	}

	public static function generateVocalsFromSections(sections:Array<SSSection>, voiceBank:Voicebank):Array<VocalGenerator>
	{
		var generators = [];
		for (section in sections)
		{
			if (section.type == 'v')
				generators.push(generateVocalsFromNotes(section.notes, voiceBank));
		}
		return generators;
	}
}
