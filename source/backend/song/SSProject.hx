package backend.song;

typedef SSProject =
{
	var name:String;
	var tracks:Array<SSTrack>;
	var voicebank:String;
	var timeSignatureNumerator:Int;
	var timeSignatureDenominator:Int;
	var settings:SSProjectSettings;
}

typedef SSTrack =
{
	var name:String;
	var sections:Array<SSSection>;
	var muted:Bool;
	var volume:Float;
}

typedef SSSection =
{
	var name:String;
	var time:Float;
	var notes:Array<Note>;
	var bpm:Float;
}

typedef SSProjectSettings =
{
	var test:Bool;
}
