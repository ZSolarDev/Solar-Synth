package backend.song;

class Note
{
	public var time:Float;
	public var pitches:Array<SongValue>;
	public var duration:Float;
	public var velocities:Array<SongValue>;
	public var phoneme:String;
	public var shortEnd:Bool = false;
	public var power:Array<SongValue>;
	public var tension:Float;
	public var atonal:Bool = false;
	public var roughness:Float;
	public var breathiness:Array<SongValue>;
	public var tone:Array<SongValue> = [];
	public var esperMode:Bool = false;
	public var mouth:Array<SongValue>;

	public function new(phoneme:String, time:Float, duration:Float, shortEnd:Bool, atonal:Bool, esperMode:Bool, tension:Float, roughness:Float,
			pitches:Array<SongValue>, velocities:Array<SongValue>, power:Array<SongValue>, breathiness:Array<SongValue>, mouth:Array<SongValue>)
	{
		this.phoneme = phoneme;
		this.time = time;
		this.duration = duration;
		this.shortEnd = shortEnd;
		this.esperMode = esperMode;
		this.pitches = pitches;
		this.tension = tension;
		this.roughness = roughness;
		this.velocities = velocities;
		this.shortEnd = shortEnd;
		this.power = power;
		this.breathiness = breathiness;
		this.mouth = mouth;
	}
}
