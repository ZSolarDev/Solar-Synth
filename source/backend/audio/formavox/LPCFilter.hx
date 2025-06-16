package backend.audio.formavox;

class LPCFilter
{
	public var f1:BiquadFilter;
	public var f2:BiquadFilter;
	public var f3:BiquadFilter;

	public function new(profile:FormaVox.FormantProfile, sampleRate:Float)
	{
		f1 = new BiquadFilter(profile.f1, 2, sampleRate);
		f2 = new BiquadFilter(profile.f2, 2, sampleRate);
		f3 = new BiquadFilter(profile.f3, 2, sampleRate);
	}

	public function process(input:Float):Float
		return f1.process(input) + f2.process(input) + f3.process(input);
}
