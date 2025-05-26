package backend.utils;

import backend.song.Note;
import backend.song.SSProject;
import backend.song.SSProjectTypedef;

class SSProjectUtil
{
	public static function typedefToProject(tp:SSProjectTypedef):SSProject
	{
		var tracks:Array<SSTrack> = [];
		for (track in tp.tracks)
		{
			var sections:Array<SSSection> = [];
			for (section in track.sections)
			{
				var notes:Array<Note> = [];
				for (note in section.notes)
					notes.push(new Note(note.phoneme, note.time, note.duration, note.shortEnd, note.atonal, note.esperMode, note.tension, note.roughness,
						note.pitches, note.velocities, note.power, note.breathiness, note.mouth));
				sections.push({
					name: section.name,
					time: section.time,
					duration: section.duration,
					type: section.type,
					soundPath: section.soundPath,
					notes: notes,
					bpm: section.bpm
				});
			}
			tracks.push({
				name: track.name,
				sections: sections,
				muted: track.muted,
				volume: track.volume
			});
		}
		return {
			name: tp.name,
			tracks: tracks,
			voicebank: tp.voicebank,
			timeSignatureNumerator: tp.timeSignatureNumerator,
			timeSignatureDenominator: tp.timeSignatureDenominator,
			settings: {
				test: tp.settings.test
			}
		};
	}

	public static function projectToTypedef(p:SSProject):SSProjectTypedef
	{
		var tracks:Array<SSTrackTypedef> = [];
		for (track in p.tracks)
		{
			var sections:Array<SSSectionTypedef> = [];
			for (section in track.sections)
			{
				var notes:Array<NoteTypeDef> = [];
				for (note in section.notes)
					notes.push({
						time: note.time,
						esperMode: note.esperMode,
						pitches: note.pitches,
						duration: note.duration,
						velocities: note.velocities,
						phoneme: note.phoneme,
						atonal: note.atonal,
						shortEnd: note.shortEnd,
						tension: note.tension,
						roughness: note.roughness,
						power: note.power,
						breathiness: note.breathiness,
						tone: note.tone,
						mouth: note.mouth,
					});
				sections.push({
					name: section.name,
					time: section.time,
					duration: section.duration,
					type: section.type,
					soundPath: section.soundPath,
					notes: notes,
					bpm: section.bpm
				});
			}
			tracks.push({
				name: track.name,
				sections: sections,
				muted: track.muted,
				volume: track.volume
			});
		}
		return {
			name: p.name,
			tracks: tracks,
			voicebank: p.voicebank,
			timeSignatureNumerator: p.timeSignatureNumerator,
			timeSignatureDenominator: p.timeSignatureDenominator,
			settings: {
				test: p.settings.test
			}
		};
	}
}
