package backend.utils;

import backend.data.Note;
import backend.data.SSProject;
import backend.data.SSProjectTypedef;
import haxe.Json;
import haxe.io.Path;
import sys.io.File;

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
					notes.push(new Note(note.phoneme, note.time, note.duration, note.automaticBlendRatio, note.blendRatio, note.atonal, note.powerValue,
						note.breathinessValue, note.tension, note.roughness, note.pitches, note.velocities, note.power, note.breathiness, note.mouth));
				sections.push({
					name: section.name,
					time: section.time,
					duration: section.duration,
					type: section.type,
					soundPath: section.soundPath,
					notes: notes,
					resampMode: section.resampMode
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
			settings: tp.settings,
			bpm: tp.bpm
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
						pitches: note.pitches,
						duration: note.duration,
						velocities: note.velocities,
						blendRatio: note.blendRatio,
						automaticBlendRatio: note.automaticBlendRatio,
						phoneme: note.phoneme,
						atonal: note.atonal,
						powerValue: note.powerValue,
						breathinessValue: note.breathinessValue,
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
					resampMode: section.resampMode
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
			settings: p.settings,
			bpm: p.bpm
		};
	}

	public static function validateProjectName(str:String):String
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

	public static function saveProjectToSSP(path:String, project:SSProject)
	{
		var proj = projectToTypedef(project);
		var finalPath = path == '' ? './' : '${Path.normalize(path)}/';
		File.saveContent(finalPath + validateProjectName(project.name) + '.ssp', Json.stringify(proj, null, '    '));
	}
}
