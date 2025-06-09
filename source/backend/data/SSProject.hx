package backend.data;

import frontend.Track;

typedef SSProject =
{
	var name:String;
	var tracks:Array<SSTrack>;
	var timeSignatureNumerator:Int;
	var timeSignatureDenominator:Int;
	var settings:SSProjectSettings;
	var bpm:Array<SongValue>;
}

typedef SSTrack =
{
	var name:String;
	var voicebank:String;
	var sections:Array<SSSection>;
	var muted:Bool;
	var volume:Float;
	var type:String;
	var pan:Float;
	var ?track:Track;
}

typedef SSSection =
{
	var name:String;
	var time:Float;
	var duration:Float;
	var soundPath:String;
	var notes:Array<Note>;
	var resampMode:Bool;
}

typedef SSProjectSettings = {}
