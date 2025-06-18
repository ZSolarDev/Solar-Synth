package backend.audio.areo;

typedef SongVal =
{
	var time:Float;
	var value:Float;
}

class Areo
{
	public static function renderBreath(samples:Array<Float>, breathValues:Array<SongVal>, sampleRate:Float):Array<Float>
	{
		try
		{
			var output = [];
			var breathVals:Array<SongVal> = [];

			for (val in breathValues)
				breathVals.push({time: val.time, value: val.value});

			// Sort breathVals by time
			breathVals.sort((a, b) -> cast a.time - b.time);
			if (breathVals.length == 0)
				breathVals.push({time: 0, value: 0});

			// Convert times to sample indices
			var indices = breathVals.map(v -> Std.int(v.time / 1000 * sampleRate));
			indices.push(samples.length); // Extra index for the last region

			var index = 0;
			var currentBreathValue = breathVals[0].value;
			var breath = new BreathRenderer(sampleRate);

			for (i in 0...samples.length)
			{
				// Safely check for range change
				if (index + 1 < indices.length && i >= indices[index + 1])
				{
					index++;
					if (index < breathVals.length)
					{
						currentBreathValue = breathVals[index].value;
					}
				}

				output[i] = breath.process(samples[i], currentBreathValue);
			}

			return output;
		}
		catch (e)
		{
			trace('${e.message}\n${e.stack}');
			return samples;
		}
	}
}
