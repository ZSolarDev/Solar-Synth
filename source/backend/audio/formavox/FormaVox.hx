package backend.audio.formavox;

import backend.utils.VocalUtil;

// formant frequencies in hz
typedef FormantProfile =
{
	var f1:Float;
	var f2:Float;
	var f3:Float;
}

class FormaVox
{
	public static var defaultProfiles:Map<String, FormantProfile> = [
		'a' => {
			f1: 800, // open mouth
			f2: 1200, // back or central
			f3: 2600
		},
		'i' => {
			f1: 300, // very closed
			f2: 2500, // very fronted
			f3: 3200
		},
		'u' => {
			f1: 350, // closed
			f2: 900, // back
			f3: 2200
		},
		'e' => {
			f1: 500,
			f2: 2000,
			f3: 2800
		},
		'o' => {
			f1: 500,
			f2: 1000,
			f3: 2400
		}
	];

	public static function getProfile(phoneme:String):FormantProfile
		return phoneme.length == 1 ? defaultProfiles.get(phoneme) : VocalUtil.isBreath(phoneme) ? {
			f1: 0,
			f2: 0,
			f3: 0
		} : defaultProfiles.get(phoneme.charAt(1));

	public static function processSamples(samples:Array<Float>, _formants:Array<FormaVoxValue>, sampleRate:Float):Array<Float>
	{
		try
		{
			var output = [];
			var formants:Array<FormaVoxValue> = [];
			for (val in _formants)
				formants.push({
					time: val.time,
					profile: val.profile
				});
			// sort formants by time
			formants.sort(function(a, b) return cast a.time - b.time);

			if (formants.length == 0)
				formants.push({
					time: 0,
					profile: {f1: 0, f2: 0, f3: 0}
				});

			// convert times to sample indices
			var indices = formants.map(v -> Std.int(v.time / 1000 * sampleRate));
			indices.push(samples.length); // add one extra for the end

			// initial filter
			var currentFormants = formants[0].profile;
			var filter = currentFormants != null ? new LPCFilter(currentFormants, sampleRate) : null;

			for (i in 0...samples.length)
			{
				// move to next mouth region if needed
				if (i >= indices[1])
				{
					formants.shift();
					indices.shift();
					if (formants.length > 0)
					{
						currentFormants = formants[0].profile;
						filter = currentFormants != null ? new LPCFilter(currentFormants, sampleRate) : null;
					}
				}

				output[i] = filter != null ? filter.process(samples[i]) : samples[i];
			}

			return output;
		}
		catch (e)
		{
			trace('${e.message}\n${e.stack.toString()}');
			return samples;
		}
	}
}
