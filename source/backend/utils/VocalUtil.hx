package backend.utils;

class VocalUtil
{
	public static function isVowel(phoneme:String):Bool
		return ["a", "i", "u", "e", "o"].indexOf(phoneme) >= 0;

	public static function isDigit(char:String):Bool
		return Std.parseFloat(char) >= 0 && Std.parseFloat(char) <= 9;

	public static function isBreath(phoneme:String):Bool
		return phoneme.startsWith("b") && isDigit(phoneme.charAt(1));
}
