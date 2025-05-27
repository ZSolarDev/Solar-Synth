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
	var duration:Float;
	var type:String;
	var soundPath:String;
	var notes:Array<Note>;
	var bpm:Float;
	var esperMode:Bool;
}

typedef SSProjectSettings =
{
	var test:Bool;
}
