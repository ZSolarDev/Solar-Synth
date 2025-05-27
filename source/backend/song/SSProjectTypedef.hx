package backend.song;

typedef SSProjectTypedef =
{
	var name:String;
	var tracks:Array<SSTrackTypedef>;
	var voicebank:String;
	var timeSignatureNumerator:Int;
	var timeSignatureDenominator:Int;
	var settings:SSProjectSettingsTypedef;
}

typedef NoteTypeDef =
{
	var time:Int;
	var pitches:Array<SongValue>;
	var duration:Int;
	var velocities:Array<SongValue>;
	var phoneme:String;
	var atonal:Bool;
	var powerValue:Float;
	var breathinessValue:Float;
	var shortEnd:Bool;
	var tension:Float;
	var roughness:Float;
	var power:Array<SongValue>;
	var breathiness:Array<SongValue>;
	var tone:Array<SongValue>;
	var mouth:Array<SongValue>;
}

typedef SSTrackTypedef =
{
	var name:String;
	var sections:Array<SSSectionTypedef>;
	var muted:Bool;
	var volume:Float;
}

typedef SSSectionTypedef =
{
	var name:String;
	var time:Float;
	var duration:Float;
	var type:String;
	var soundPath:String;
	var notes:Array<NoteTypeDef>;
	var bpm:Float;
	var esperMode:Bool;
}

typedef SSProjectSettingsTypedef =
{
	var test:Bool;
}
