package backend.audio.formavox;

class BiquadFilter
{
	public var a0:Float;
	public var a1:Float;
	public var a2:Float;
	public var b0:Float;
	public var b1:Float;
	public var b2:Float;

	public var x1:Float = 0;
	public var x2:Float = 0;
	public var y1:Float = 0;
	public var y2:Float = 0;

	public function new(centerFreq:Float, Q:Float, sampleRate:Float)
	{
		var omega = 2 * Math.PI * centerFreq / sampleRate;
		var alpha = Math.sin(omega) / (2 * Q);
		var cosw = Math.cos(omega);

		b0 = alpha;
		b1 = 0;
		b2 = -alpha;
		a0 = 1 + alpha;
		a1 = -2 * cosw;
		a2 = 1 - alpha;

		b0 /= a0;
		b1 /= a0;
		b2 /= a0;
		a1 /= a0;
		a2 /= a0;
	}

	public function process(x:Float, amp:Float = 2):Float
	{
		var y = b0 * x + b1 * x1 + b2 * x2 - a1 * y1 - a2 * y2;
		x2 = x1;
		x1 = x;
		y2 = y1;
		y1 = y;
		return y * amp;
	}

	public function updateFrequency(centerFreq:Float, sampleRate:Float):Void
	{
		var omega = 2 * Math.PI * centerFreq / sampleRate;
		var alpha = Math.sin(omega) / (2 * 2); // assuming Q=2 like before
		var cosw = Math.cos(omega);

		b0 = alpha;
		b1 = 0;
		b2 = -alpha;
		a0 = 1 + alpha;
		a1 = -2 * cosw;
		a2 = 1 - alpha;

		b0 /= a0;
		b1 /= a0;
		b2 /= a0;
		a1 /= a0;
		a2 /= a0;
	}
}
