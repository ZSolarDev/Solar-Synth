package fft;

class Complex
{
	public var re:Float;
	public var im:Float;

	public function new(re:Float, im:Float)
	{
		this.re = re;
		this.im = im;
	}

	public static function polar(magnitude:Float, phase:Float):Complex
		return new Complex(magnitude * Math.cos(phase), magnitude * Math.sin(phase));
}
