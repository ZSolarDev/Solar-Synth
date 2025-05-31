package backend.song;

class Note
{
	public var time:Int;
	public var pitches:Array<SongValue>;
	public var duration:Int;
	public var velocities:Array<SongValue>;
	public var phoneme:String;
	public var power:Array<SongValue>;
	public var tension:Float;
	public var atonal:Bool = false;
	public var roughness:Float;
	public var powerValue:Float;
	public var breathinessValue:Float;
	public var breathiness:Array<SongValue>;
	public var tone:Array<SongValue> = [];
	public var mouth:Array<SongValue>;
	public var blendRatio:Int = 0;
	public var automaticBlendRatio:Bool = false;

	public function new(phoneme:String, time:Int, duration:Int, automaticBlendRatio:Bool, blendRatio:Int, atonal:Bool, powerValue:Float,
			breathinessValue:Float, tension:Float, roughness:Float, pitches:Array<SongValue>, velocities:Array<SongValue>, power:Array<SongValue>,
			breathiness:Array<SongValue>, mouth:Array<SongValue>)
	{
		this.phoneme = phoneme;
		this.time = time;
		this.duration = duration;
		this.automaticBlendRatio = automaticBlendRatio;
		this.blendRatio = blendRatio;
		this.atonal = atonal;
		this.powerValue = powerValue;
		this.breathinessValue = breathinessValue;
		this.pitches = pitches;
		this.tension = tension;
		this.roughness = roughness;
		this.velocities = velocities;
		this.power = power;
		this.breathiness = breathiness;
		this.mouth = mouth;
	}
}
