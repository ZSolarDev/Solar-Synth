package backend.utils;

class VocalUtil
{
	public static function isVowel(phoneme:String):Bool
		return ["a", "i", "u", "e", "o"].indexOf(phoneme) >= 0;

	public static function isPlosive(phoneme:String):Bool
		return isVowel(phoneme) ? false : isBreath(phoneme) ? false : phoneme.startsWith("k") || phoneme.startsWith("t") || phoneme.startsWith("p")
			|| phoneme.startsWith("g") || phoneme.startsWith("d") || phoneme.startsWith("b") || phoneme.startsWith("k") || phoneme.startsWith("c");

	public static function isContinuant(phoneme:String):Bool
		return isVowel(phoneme) || (!isBreath(phoneme) && !isPlosive(phoneme));

	public static function isDigit(char:String):Bool
		return Std.parseFloat(char) >= 0 && Std.parseFloat(char) <= 9;

	public static function isBreath(phoneme:String):Bool
		return phoneme.startsWith("b") && isDigit(phoneme.charAt(1));
}
