package backend.audio.vocal;

import backend.song.SongValue;

class PitchBendEncoder
{
	static inline var PITCH_BEND_RANGE = 24.0; // semitones
	static inline var BASE64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

	public static function encodePitchBend(values:Array<SongValue>, targetDur:Int):String
	{
		if (values.length == 0 || targetDur <= 0)
			return "";

		var result = "";
		var section:Array<Int> = [];

		// just in case
		values.sort((a, b) -> Std.int(a.time - b.time));

		var totalTime = values[values.length - 1].time;
		var timeStep = totalTime / targetDur;

		var output:Array<Int> = [];

		var currentIndex = 0;
		var currentValue = values[0].value;

		for (i in 0...targetDur)
		{
			var currentTime = i * timeStep;
			while (currentIndex < values.length && values[currentIndex].time <= currentTime)
			{
				currentValue = values[currentIndex].value;
				currentIndex++;
			}

			output.push(encodeValue(currentValue));
		}

		var last = output[0];
		section.push(last);
		var i = 1;

		while (i < output.length)
		{
			var current = output[i];

			var repeatCount = 0;
			while (i < output.length && current == last)
			{
				repeatCount++;
				i++;
			}

			if (repeatCount > 0)
			{
				result += encodeSection(section) + "#";
				result += repeatCount + "#";

				if (i < output.length)
				{
					last = output[i];
					section = [last];
					i++;
				}
			}
			else
			{
				section.push(current);
				last = current;
				i++;
			}
		}

		if (section.length > 0)
			result += encodeSection(section);

		trace(result);
		return result;
	}

	static function encodeSection(data:Array<Int>):String
	{
		var out = "";
		for (v in data)
			out += encodeBase64Value(v);
		return out;
	}

	static function encodeValue(value:Float):Int // Why does Utau work like this??
	{
		var cents = value * 100.0;
		var scaled = cents * (2047 / (PITCH_BEND_RANGE * 100.0));
		return Std.int(Math.max(-2048, Math.min(2047, Math.round(scaled))));
	}

	static function encodeBase64Value(value:Int):String
	{
		var BASE64 = BASE64;
		if (value < 0)
			value += 4096;
		var hi = (value >> 6) & 0x3F;
		var lo = value & 0x3F;
		return BASE64.charAt(hi) + BASE64.charAt(lo);
	}
}
