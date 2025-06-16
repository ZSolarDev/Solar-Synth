package backend.audio.kenetix;

import backend.data.*;
import haxe.Timer;
import openfl.media.Sound;

class Kenetix
{
	public static var sound(get, null):Sound;
	public static var bytes(get, null):Bytes;
	public static var synthesized(get, null):Bool;

	static function get_synthesized():Bool
		return VocalSynthesizer.synthesized;

	public static function get_sound():Sound
		return VocalSynthesizer.sound;

	public static function get_bytes():Bytes
		return VocalSynthesizer.bytes;

	public static function synthesizeVocals(notes:Array<Note>, voiceBank:Voicebank, resampMode:Bool)
	{
		VocalSynthesizer.synthesized = false;
		VocalSynthesizer.threadedSynthesizer = new VocalSynthesizerThreaded(notes, voiceBank, resampMode);
		VocalSynthesizer.threadedSynthesizer.runBatches();
		VocalSynthesizer.timer = new Timer(0.001);
		VocalSynthesizer.timer.run = VocalSynthesizer.waitForVocals;
	}
}
