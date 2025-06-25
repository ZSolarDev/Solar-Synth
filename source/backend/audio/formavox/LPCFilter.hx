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

	// update filter center freqs without resetting state
	public function updateProfile(profile:FormaVox.FormantProfile, sampleRate:Float):Void
	{
		f1.updateFrequency(profile.f1, sampleRate);
		f2.updateFrequency(profile.f2, sampleRate);
		f3.updateFrequency(profile.f3, sampleRate);
	}

	public function process(input:Float):Float
		return f1.process(input) + f2.process(input) + f3.process(input);
}
