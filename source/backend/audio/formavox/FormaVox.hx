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

	public static function processSamples(samples:Array<Float>, _formants:Array<FormaVoxValue>, sampleRate:Float, interpolate:Bool = false):Array<Float>
	{
		var output = [];
		var formants:Array<FormaVoxValue> = [];
		for (val in _formants)
			formants.push({
				time: val.time,
				profile: val.profile
			});
		formants.sort((a, b) -> return cast a.time - b.time);
		if (formants.length == 0)
			formants.push({
				time: 0,
				profile: {f1: 0, f2: 0, f3: 0}
			});
		var indices = formants.map(v -> Std.int(v.time / 1000 * sampleRate));
		indices.push(samples.length);

		var currentFormants = formants[0].profile;
		var nextFormants:FormaVox.FormantProfile = null;
		var formantStartIndex = indices[0];
		var formantEndIndex = indices[1];
		var formantRange = formantEndIndex - formantStartIndex;

		var filter:LPCFilter = currentFormants != null ? new LPCFilter(currentFormants, sampleRate) : null;

		for (i in 0...samples.length)
		{
			if (i >= formantEndIndex)
			{
				formants.shift();
				indices.shift();
				if (formants.length > 0)
				{
					currentFormants = formants[0].profile;
					formantStartIndex = indices[0];
					formantEndIndex = indices[1];
					formantRange = formantEndIndex - formantStartIndex;
				}
				nextFormants = null;

				// On formant change without interpolation, update filter once to new formants
				if (!interpolate && filter != null && currentFormants != null)
					filter.updateProfile(currentFormants, sampleRate);
			}

			if (interpolate)
			{
				// Prepare next formants for interpolation if available
				if (formants.length > 1)
					nextFormants = formants[1].profile;
				else
					nextFormants = currentFormants;

				var ratio:Float = 0.0;
				if (formantRange > 0)
					ratio = (i - formantStartIndex) / formantRange;

				var interpFormants = {
					f1: currentFormants.f1 * (1 - ratio) + nextFormants.f1 * ratio,
					f2: currentFormants.f2 * (1 - ratio) + nextFormants.f2 * ratio,
					f3: currentFormants.f3 * (1 - ratio) + nextFormants.f3 * ratio
				};

				if (filter != null)
					filter.updateProfile(interpFormants, sampleRate);
			}

			output[i] = filter != null ? filter.process(samples[i]) : samples[i];
		}
		return output;
	}

	public static function processSamplesBySamples(samples:Array<Float>, _formants:Array<FormaVoxValue>, sampleRate:Float,
			interpolate:Bool = false):Array<Float>
	{
		var output = [];
		var formants:Array<FormaVoxValue> = [];

		for (val in _formants)
			formants.push({
				time: val.time,
				profile: val.profile
			});

		formants.sort((a, b) -> return cast a.time - b.time);

		if (formants.length == 0)
			formants.push({
				time: 0,
				profile: {f1: 0, f2: 0, f3: 0}
			});

		var indices = formants.map(v -> v.time);
		indices.push(samples.length);

		var currentFormants = formants[0].profile;
		var nextFormants:FormaVox.FormantProfile = null;
		var formantStartIndex = indices[0];
		var formantEndIndex = indices[1];
		var formantRange = formantEndIndex - formantStartIndex;

		var filter:LPCFilter = currentFormants != null ? new LPCFilter(currentFormants, sampleRate) : null;

		for (i in 0...samples.length)
		{
			if (i >= formantEndIndex)
			{
				formants.shift();
				indices.shift();
				if (formants.length > 0)
				{
					currentFormants = formants[0].profile;
					formantStartIndex = indices[0];
					formantEndIndex = indices[1];
					formantRange = formantEndIndex - formantStartIndex;
				}
				nextFormants = null;

				if (!interpolate && filter != null && currentFormants != null)
					filter.updateProfile(currentFormants, sampleRate);
			}

			if (interpolate)
			{
				if (formants.length > 1)
					nextFormants = formants[1].profile;
				else
					nextFormants = currentFormants;

				var ratio:Float = 0.0;
				if (formantRange > 0)
					ratio = (i - formantStartIndex) / formantRange;

				var interpFormants = {
					f1: currentFormants.f1 * (1 - ratio) + nextFormants.f1 * ratio,
					f2: currentFormants.f2 * (1 - ratio) + nextFormants.f2 * ratio,
					f3: currentFormants.f3 * (1 - ratio) + nextFormants.f3 * ratio
				};

				if (filter != null)
					filter.updateProfile(interpFormants, sampleRate);
			}

			output[i] = filter != null ? filter.process(samples[i]) : samples[i];
		}
		return output;
	}
}
