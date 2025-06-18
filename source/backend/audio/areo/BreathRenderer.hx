package backend.audio.areo;

class BreathRenderer
{
	public var low:BiquadFilter;
	public var lowMid:BiquadFilter;
	public var mid:BiquadFilter;
	public var high:BiquadFilter;

	public function new(sampleRate:Float)
	{
		low = new BiquadFilter(250, 1.0, sampleRate);
		lowMid = new BiquadFilter(750, 1.0, sampleRate);
		mid = new BiquadFilter(2000, 1.0, sampleRate);
		high = new BiquadFilter(6000, 1.0, sampleRate);
	}

	public function process(input:Float, breathValue:Float):Float
	{
		inline function gain(bv:Float, start:Float, end:Float):Float
			return (bv < start) ? 0 : (bv > end) ? 1 : (bv - start) / (end - start);

		var lowAmt = gain(breathValue, 0, 10);
		var lowMidAmt = gain(breathValue, 10, 40);
		var midAmt = gain(breathValue, 40, 70);
		var highAmt = gain(breathValue, 70, 100);

		return (low.process(input) * lowAmt
			+ lowMid.process(input) * lowMidAmt
			+ mid.process(input) * midAmt
			+ high.process(input) * highAmt);
	}
}
