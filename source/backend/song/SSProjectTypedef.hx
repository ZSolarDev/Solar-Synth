package backend.song;

typedef SSProjectTypedef =
{
	var name:String;
	var tracks:Array<SSTrackTypedef>;
	var voicebank:String;
	var bpms:Array<SongValue>;
	var timeSignature:Float;
	var settings:SSProjectSettingsTypedef;
}

typedef NoteTypeDef =
{
	var time:Float;
	var pitches:Array<SongValue>;
	var duration:Float;
	var velocities:Array<SongValue>;
	var phoneme:String;
	var loopStart:Float;
	var loopEnd:Float;
	var shortEnd:Bool;
	var power:Array<SongValue>;
	var breathiness:Array<SongValue>;
	var tone:Array<SongValue>;
	var mouth:Array<SongValue>;
}

typedef SSTrackTypedef =
{
	var name:String;
	var notes:Array<NoteTypeDef>;
	var muted:Bool;
	var volume:Float;
}

typedef SSProjectSettingsTypedef =
{
	var test:Bool;
}
