package backend.song;

typedef Voicebank =
{
	var samples:Map<String, String>;
	var icon:String;
	var name:String;
	var description:String;
	var singer:String;
	var credits:Array<String>;
	var language:String;
	var sampleStart:Float;
	var consonantSampleStart:Float;
	var consonantBlendRatio:Float;
	var vowelBlendRatio:Float;
	var mouth:Bool;
	var breaths:Bool;
	var mouthBreath:Bool;
	var power:Bool;
	var mouthPower:Bool;
	var soft:Bool;
	var mouthSoft:Bool;
	var breathSamples:Int;
}
