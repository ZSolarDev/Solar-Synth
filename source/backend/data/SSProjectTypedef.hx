package backend.data;

import backend.data.SongValue;

typedef SSProjectTypedef =
{
	var name:String;
	var tracks:Array<SSTrackTypedef>;
	var voicebank:String;
	var timeSignatureNumerator:Int;
	var timeSignatureDenominator:Int;
	var settings:SSProjectSettingsTypedef;
	var bpm:Array<SongValue>;
}

typedef NoteTypeDef =
{
	var time:Int;
	var pitches:Array<SongValue>;
	var duration:Int;
	var velocities:Array<SongValue>;
	var blendRatio:Int;
	var automaticBlendRatio:Bool;
	var phoneme:String;
	var atonal:Bool;
	var powerValue:Float;
	var breathinessValue:Float;
	var tension:Float;
	var roughness:Float;
	var power:Array<SongValue>;
	var breathiness:Array<SongValue>;
	var tone:Array<SongValue>;
	var mouth:Array<SongValue>;
	var sampleStartOffset:Int;
}

typedef SSTrackTypedef =
{
	var name:String;
	var sections:Array<SSSectionTypedef>;
	var muted:Bool;
	var type:String;
	var volume:Float;
	var pan:Float;
}

typedef SSSectionTypedef =
{
	var name:String;
	var time:Float;
	var duration:Float;
	var soundPath:String;
	var notes:Array<NoteTypeDef>;
	var resampMode:Bool;
}

typedef SSProjectSettingsTypedef = {}
