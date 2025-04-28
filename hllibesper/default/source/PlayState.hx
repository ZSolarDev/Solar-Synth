package;

import fft.*;
import flixel.FlxState;
import haxe.io.Bytes;
import hl.F32;
import hl.NativeArray;
import libesper.LibESPER;
import sys.io.File;

class PlayState extends FlxState
{
	static function getInt16(bytes:Bytes, index:Int, littleEndian:Bool = true):Int
	{
		if (littleEndian)
		{
			@:privateAccess
			var value = bytes.b[index] | (bytes.b[index + 1] << 8);
			if ((value & 0x8000) != 0)
				value -= 0x10000;
			return value;
		}
		else
		{
			@:privateAccess
			var value = (bytes.b[index] << 8) | bytes.b[index + 1];
			if ((value & 0x8000) != 0)
				value -= 0x10000;
			return value;
		}
	}

	static function setInt16(bytes:Bytes, index:Int, value:Int, littleEndian:Bool = true)
	{
		if (littleEndian)
		{
			if (value < 0)
				value += 0x10000;
			@:privateAccess
			bytes.b[index] = value & 0xff;
			@:privateAccess
			bytes.b[index + 1] = (value >> 8) & 0xff;
		}
		else
		{
			if (value < 0)
				value += 0x10000;
			@:privateAccess
			bytes.b[index] = (value >> 8) & 0xff;
			@:privateAccess
			bytes.b[index + 1] = value & 0xff;
		}
	}

	static function clamp(value:Int, min:Int, max:Int):Int
		return value < min ? min : (value > max ? max : value);

	static function createWavHeader(numSamples:Int, numChannels:Int, sampleRate:Int, bitsPerSample:Int):Bytes
	{
		var dataSize:Int = numSamples * numChannels * (bitsPerSample >> 3);
		var headerSize:Int = 44;
		var header:Bytes = Bytes.alloc(headerSize);

		header.set(0, "R".charCodeAt(0));
		header.set(1, "I".charCodeAt(0));
		header.set(2, "F".charCodeAt(0));
		header.set(3, "F".charCodeAt(0));

		var fileSize:Int = dataSize + 36;
		header.set(4, fileSize & 0xff);
		header.set(5, (fileSize >> 8) & 0xff);
		header.set(6, (fileSize >> 16) & 0xff);
		header.set(7, (fileSize >> 24) & 0xff);

		header.set(8, "W".charCodeAt(0));
		header.set(9, "A".charCodeAt(0));
		header.set(10, "V".charCodeAt(0));
		header.set(11, "E".charCodeAt(0));

		header.set(12, "f".charCodeAt(0));
		header.set(13, "m".charCodeAt(0));
		header.set(14, "t".charCodeAt(0));
		header.set(15, " ".charCodeAt(0));

		header.set(16, 16);
		header.set(17, 0);
		header.set(18, 0);
		header.set(19, 0);

		header.set(20, 1);
		header.set(21, 0);

		header.set(22, numChannels & 0xff);
		header.set(23, (numChannels >> 8) & 0xff);

		header.set(24, sampleRate & 0xff);
		header.set(25, (sampleRate >> 8) & 0xff);
		header.set(26, (sampleRate >> 16) & 0xff);
		header.set(27, (sampleRate >> 24) & 0xff);

		var byteRate:Int = sampleRate * numChannels * (bitsPerSample >> 3);
		header.set(28, byteRate & 0xff);
		header.set(29, (byteRate >> 8) & 0xff);
		header.set(30, (byteRate >> 16) & 0xff);
		header.set(31, (byteRate >> 24) & 0xff);

		var blockAlign:Int = numChannels * (bitsPerSample >> 3);
		header.set(32, blockAlign & 0xff);
		header.set(33, (blockAlign >> 8) & 0xff);

		header.set(34, bitsPerSample & 0xff);
		header.set(35, (bitsPerSample >> 8) & 0xff);

		header.set(36, "d".charCodeAt(0));
		header.set(37, "a".charCodeAt(0));
		header.set(38, "t".charCodeAt(0));
		header.set(39, "a".charCodeAt(0));

		header.set(40, dataSize & 0xff);
		header.set(41, (dataSize >> 8) & 0xff);
		header.set(42, (dataSize >> 16) & 0xff);
		header.set(43, (dataSize >> 24) & 0xff);

		return header;
	}

	override public function create()
	{
		super.create();
		var ogSample = File.getBytes('assets/test.wav');
		ogSample = ogSample.sub(44, ogSample.length - 44);
		var totalSamples:Int = cast ogSample.length / 2;
		var samples:Array<Float> = [];
		for (i in 0...totalSamples)
		{
			var offset = i * 2;
			if (offset + 2 <= ogSample.length)
				samples.push(getInt16(ogSample, offset, true) / 32768.0);
			else
				samples.push(0.0);
		}
		var breathiness = [0.0];
		for (i in 0...samples.length * 2)
			breathiness[i] = 0.5;
		LibESPER.applyBreathiness(samples, breathiness);
		var finalSample = Bytes.alloc(cast samples.length * 2);
		for (i in 0...samples.length)
		{
			var sample = Std.int(clamp(cast samples[i] * 32767, -32768, 32767));
			setInt16(finalSample, i * 2, sample, true);
		}
		var wavHeader:Bytes = createWavHeader(totalSamples, 1, 44100, 2);
		var complete:Bytes = Bytes.alloc(wavHeader.length + finalSample.length);
		complete.blit(0, wavHeader, 0, wavHeader.length);
		complete.blit(wavHeader.length, finalSample, 0, finalSample.length);
		File.saveBytes('testfftTest.wav', complete);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
