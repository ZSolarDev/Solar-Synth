package backend.audio.vocal;

import backend.song.SongValue;

class PitchBendEncoder
{
	static inline var PITCH_BEND_RANGE = 24.0; // semitones
	static inline var BASE64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

	public static function encodePitchBend(values:Array<SongValue>):String
	{
		if (values.length == 0)
			return "";

		var result = "";
		var section:Array<Int> = [];
		var last:Int = encodeValue(values[0].value);
		section.push(last);

		var i = 1;
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

				if (i < values.length)
				{
					last = encodeValue(values[i].value);
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
		var inverted = -value;
		if (inverted < 0)
			inverted += 4096;
		var hi = (inverted >> 6) & 0x3F;
		var lo = inverted & 0x3F;
		return BASE64.charAt(hi) + BASE64.charAt(lo);
	}
}
