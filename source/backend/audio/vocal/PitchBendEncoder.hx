package backend.audio.vocal;

import backend.song.SongValue;

class PitchBendEncoder
{
	static inline var PITCH_BEND_RANGE = 24.0; // semitones
	static inline var BASE64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

	public static function encodePitchBend(values:Array<SongValue>, targetDur:Int):String
	{
		if (values.length == 0)
			return "";

		var result = "";
		var section:Array<Int> = [];
		var last:Int = encodeValue(values[0].value);
		section.push(last);

		var i = 1;
		var encodedCount = 1; // we've added one so far

		while (i < values.length)
		{
			var current = encodeValue(values[i].value);

			var repeatCount = 0;
			while (i < values.length && current == last)
			{
				repeatCount++;
				i++;
			}

			if (repeatCount > 0)
			{
				result += encodeSection(section) + "#";
				result += repeatCount + "#";
				encodedCount += section.length + repeatCount;

				if (i < values.length)
				{
					last = encodeValue(values[i].value);
					section = [last];
					i++;
					encodedCount++;
				}
			}
			else
			{
				section.push(current);
				last = current;
				i++;
				encodedCount++;
			}
		}

		if (section.length > 0)
		{
			result += encodeSection(section);
			encodedCount += section.length;
		}

		if (encodedCount < targetDur)
		{
			var padCount = targetDur - encodedCount;
			result += "#" + padCount + "#";
		}

		return result;
	}

	static function encodeSection(data:Array<Int>):String
	{
		var out = "";
		for (v in data)
			out += encodeBase64Value(v);
		return out;
	}

	static function encodeValue(value:Float):Int
	{
		var scaled = value * (2048 / PITCH_BEND_RANGE);
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
