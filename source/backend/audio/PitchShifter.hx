package backend.audio;

import backend.song.SongValue;

class PitchShifter
{
	public static function process(buffer:Array<Float>, sampleRate:Int, pitchParams:Array<SongValue>):Array<Float>
	{
		pitchParams.sort((a, b) -> Std.int(a.time - b.time));
		var output = [];
		var lastEnd = 0.0;

		// Add implicit start marker if needed
		if (pitchParams[0].time > 0)
		{
			pitchParams.unshift({time: 0.0, value: 0.0});
		}

		for (i in 0...pitchParams.length)
		{
			var current = pitchParams[i];
			var nextTime = (i < pitchParams.length - 1) ? pitchParams[i + 1].time : Math.POSITIVE_INFINITY;

			// Convert time markers to samples
			var startSample = Std.int(current.time * sampleRate / 1000);
			var endSample = Std.int(Math.min(nextTime * sampleRate / 1000, buffer.length));

			// Get audio segment and pitch ratio
			var segment = buffer.slice(startSample, endSample);
			var pitchRatio = Math.pow(2, current.value / 12);

			// Resample to natural duration for this pitch
			var resampled = resample(segment, pitchRatio);
			output = output.concat(resampled);

			lastEnd = nextTime;
		}

		return output;
	}

	static function resample(input:Array<Float>, ratio:Float):Array<Float>
	{
		var output = [];
		var pos = 0.0;
		while (pos < input.length)
		{
			var idx = Std.int(pos);
			var frac = pos - idx;
			var a = input[idx];
			var b = (idx + 1 < input.length) ? input[idx + 1] : 0.0;
			output.push(a + frac * (b - a));
			pos += ratio;
		}
		return output;
	}
}
