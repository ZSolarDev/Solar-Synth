package backend.utils;

import haxe.io.BytesInput;
import haxe.io.BytesOutput;
import sys.io.File;

class AudioUtil
{
	public static function createWavHeader(numSamples:Int, numChannels:Int, sampleRate:Int, bitsPerSample:Int):Bytes
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

	public static function writeWavFile(samples:Array<Float>, filePath:String, sampleRate:Int)
	{
		var numChannels = 1;
		var bitsPerSample = 16;
		var header = createWavHeader(samples.length, numChannels, sampleRate, bitsPerSample);

		var bytes = Bytes.alloc(header.length + samples.length * 2);
		bytes.blit(0, header, 0, header.length);

		// write samples after header
		for (i in 0...samples.length)
		{
			// clamp/convert
			var s = Std.int(samples[i] * 32767);
			if (s > 32767)
				s = 32767;
			if (s < -32768)
				s = -32768;

			var byteIndex = header.length + i * 2;
			bytes.set(byteIndex, s & 0xFF);
			bytes.set(byteIndex + 1, (s >> 8) & 0xFF);
		}

		File.saveBytes(filePath, bytes);
	}

	public static function floatArrayToPCM16Bytes(samples:Array<Float>):Bytes
	{
		final output = new BytesOutput();
		for (sample in samples)
		{
			// clamp to [-1.0, 1.0] just in case
			var s = Math.max(-1.0, Math.min(1.0, sample));
			var intSample = Std.int(s * 32767);
			output.writeInt16(intSample);
		}
		return output.getBytes();
	}

	public static function floatArrayToWav(samples:Array<Float>, sampleRate:Int = 44100, channels:Int = 1):Bytes
	{
		final bitsPerSample = 16;
		final pcmBytes = floatArrayToPCM16Bytes(samples);
		final header = createWavHeader(Std.int(pcmBytes.length / (bitsPerSample >> 3)), // numSamples
			channels, sampleRate, bitsPerSample);

		final output = new BytesOutput();
		output.write(header);
		output.write(pcmBytes);
		return output.getBytes();
	}

	public static function pcm16BytesToFloatArray(pcmBytes:Bytes):Array<Float>
	{
		final input = new BytesInput(pcmBytes);
		final sampleCount = pcmBytes.length >> 1; // 2 bytes per sample
		final result = new Array<Float>();
		for (_ in 0...sampleCount)
		{
			var intSample = input.readInt16();
			var floatSample = intSample / 32768.0;
			result.push(floatSample);
		}
		return result;
	}

	public static function readWavFile(filePath:String):Array<Float>
	{
		var input = File.read(filePath);
		var bytes = input.readAll();
		input.close();

		var stream = new BytesInput(bytes);

		if (stream.readString(4) != "RIFF")
			throw "Not a RIFF file";
		stream.readInt32(); // skip file size
		if (stream.readString(4) != "WAVE")
			throw "Not a WAVE file";

		// find fmt
		while (true)
		{
			var id = stream.readString(4);
			var size = stream.readInt32();
			if (id == "fmt ")
				break;
			stream.read(size); // skip
		}

		// parse fmt
		var format = stream.readUInt16();
		var channels = stream.readUInt16();
		var sampleRate = stream.readInt32();
		stream.readInt32(); // byteRate
		stream.readUInt16(); // blockAlign
		var bitsPerSample = stream.readUInt16();

		// skip any extra fmt bytes
		var remainingFmt = 16 - 16; // if fmt size was bigger than 16
		if (remainingFmt > 0)
			stream.read(remainingFmt);

		// find the "data" chunk
		while (true)
		{
			var id = stream.readString(4);
			var size = stream.readInt32();
			if (id == "data")
			{
				var sampleCount = size >> 1; // 2 bytes per sample
				var result = new Array<Float>();
				for (_ in 0...sampleCount)
					result.push(stream.readInt16() / 32768);
				return result;
			}
			else
				stream.read(size); // skip unknown chunk
		}
	}
}
