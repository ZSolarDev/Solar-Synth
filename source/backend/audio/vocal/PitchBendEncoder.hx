package backend.audio.vocal;

class PitchBendEncoder
{
	public static final BASE64_CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

	public static function encodePitchBend(data:Array<Int>):String
	{
		var out = new StringBuf();

		for (n in data)
		{
			if (n < -2048 || n > 2047)
				throw 'Failed to encode pitch bend! Value $n is outside of 12-bit signed range.';
			var val = n + 2048; // convert to unsigned 12-bit

			// split into two 6-bit values
			var high = (val >> 6) & 0x3F;
			var low = val & 0x3F;

			out.add(BASE64_CHARS.charAt(high));
			out.add(BASE64_CHARS.charAt(low));
		}

		return out.toString();
	}
}
