package backend.audio;

import haxe.io.Bytes;
import haxe.io.BytesBuffer;
import haxe.io.BytesOutput;

/* omg what is thiss 😭 never again bro. I do NOT like making vocal synths.. 
	I just added a bunch of comments so i can remember what everything was can tbh im not remembering this shit..
 */
class ConvertFormat
{
	static function findChunk(bytes:Bytes, id:String):{offset:Int, size:Int}
	{
		var pos = 12; // riff header is 12 bytes long
		var idBytes = Bytes.ofString(id);

		while (pos + 8 < bytes.length)
		{
			var match = true;
			for (i in 0...4)
			{
				if (bytes.get(pos + i) != idBytes.get(i))
				{
					match = false;
					break;
				}
			}

			if (match)
			{
				var size = getUInt32(bytes, pos + 4);
				return {offset: pos, size: size};
			}

			// move to next chunk
			var chunkSize = getUInt32(bytes, pos + 4);
			pos += 8 + chunkSize;

			if (chunkSize % 2 != 0)
				pos += 1;
		}

		return null;
	}

	static function getUInt32(b:Bytes, pos:Int):Int
	{
		return b.get(pos) | (b.get(pos + 1) << 8) | (b.get(pos + 2) << 16) | (b.get(pos + 3) << 24);
	}

	static function setUInt32Bytes(bytes:Bytes, pos:Int, value:Int):Void
	{
		bytes.set(pos, value & 0xFF);
		bytes.set(pos + 1, (value >> 8) & 0xFF);
		bytes.set(pos + 2, (value >> 16) & 0xFF);
		bytes.set(pos + 3, (value >> 24) & 0xFF);
	}

	static function setUInt32(output:BytesOutput, value:Int)
	{
		output.writeByte(value & 0xFF);
		output.writeByte((value >> 8) & 0xFF);
		output.writeByte((value >> 16) & 0xFF);
		output.writeByte((value >> 24) & 0xFF);
	}

	static function bytesConcat(a:Bytes, b:Bytes):Bytes
	{
		var buf = new BytesBuffer();
		buf.addBytes(a, 0, a.length);
		buf.addBytes(b, 0, b.length);
		return buf.getBytes();
	}

	public static function convertWav(wavBytes:Bytes, startTime:Float = 0):Bytes
	{
		// riff header check
		if (wavBytes.length < 12 || wavBytes.getString(0, 4) != "RIFF")
		{
			trace("Not a valid RIFF file");
			return null;
		}

		// wave format check
		if (wavBytes.getString(8, 4) != "WAVE")
		{
			trace("Not a WAVE file");
			return null;
		}

		// fmt
		var fmtChunk = findChunk(wavBytes, "fmt ");
		if (fmtChunk == null)
		{
			trace("fmt chunk not found");
			return null;
		}

		var audioFormat = wavBytes.getUInt16(fmtChunk.offset + 8);
		var channels = wavBytes.getUInt16(fmtChunk.offset + 10);
		var sampleRate = getUInt32(wavBytes, fmtChunk.offset + 12);
		var byteRate = getUInt32(wavBytes, fmtChunk.offset + 16);
		var blockAlign = wavBytes.getUInt16(fmtChunk.offset + 20);
		var bitsPerSample = wavBytes.getUInt16(fmtChunk.offset + 22);

		// only support pcm for now(most likely will only support pcm, i'm lazy asfff)
		if (audioFormat != 1)
		{
			trace("Only PCM format supported");
			return null;
		}

		var dataChunk = findChunk(wavBytes, "data");
		if (dataChunk == null)
		{
			trace("data chunk not found");
			return null;
		}

		var dataStart = dataChunk.offset + 8;
		var dataSize = dataChunk.size;
		var dataEnd = dataStart + dataSize;

		var bytesPerSample = Std.int(bitsPerSample / 8);
		var bytesPerFrame = bytesPerSample * channels;
		var numFrames = Std.int(dataSize / bytesPerFrame);
		var totalDuration = numFrames / sampleRate;

		var startFrame = Std.int(startTime / 1000 * sampleRate);
		if (startFrame < 0)
			startFrame = 0;
		if (startFrame >= numFrames)
		{
			trace("Start time is beyond the file duration: " + startTime + " >= " + totalDuration);
			return null;
		}

		// available frames after startTime
		var availableFrames = numFrames - startFrame;

		// 16-bit mono output
		var outputSamples = new BytesOutput();

		for (frame in startFrame...numFrames)
		{
			var frameOffset = dataStart + frame * bytesPerFrame;

			if (channels == 2)
			{
				// stereo to mono
				var left = readSample(wavBytes, frameOffset, bytesPerSample, bitsPerSample);
				var right = readSample(wavBytes, frameOffset + bytesPerSample, bytesPerSample, bitsPerSample);
				var mono = Std.int((left + right) / 2);
				writeSample(outputSamples, mono, 16);
			}
			else
			{
				// already mono, convert bit depth if needed
				var sample = readSample(wavBytes, frameOffset, bytesPerSample, bitsPerSample);
				writeSample(outputSamples, sample, 16);
			}
		}

		var outputData = outputSamples.getBytes();

		var output = new BytesOutput();

		output.writeString("RIFF");
		setUInt32(output, 4); // placeholder for file size
		output.writeString("WAVE");

		output.writeString("fmt ");
		setUInt32(output, 16);

		// audio format (pcm ofc)
		output.writeByte(1);
		output.writeByte(0);

		// 1 channel
		output.writeByte(1);
		output.writeByte(0);

		setUInt32(output, sampleRate);

		// byte rate (sampleRate * numChannels * bitsPerSample/8)
		var newByteRate = sampleRate * 1 * 2;
		setUInt32(output, newByteRate);

		// block align (numChannels * bitsPerSample/8)
		output.writeByte(2); // 1 channel * 16 bits / 8 = 2
		output.writeByte(0);

		// bits per sample
		output.writeByte(16);
		output.writeByte(0);

		// data chunk
		output.writeString("data");
		setUInt32(output, outputData.length);
		output.writeBytes(outputData, 0, outputData.length);

		var finalWav = output.getBytes();
		setUInt32Bytes(finalWav, 4, finalWav.length - 8);

		return finalWav;
	}

	static function readSample(bytes:Bytes, offset:Int, bytesPerSample:Int, bitsPerSample:Int):Int
	{
		return switch (bitsPerSample)
		{
			case 8: (bytes.get(offset) - 128) << 8;
			case 16: getInt16(bytes, offset);
			case 24:
				var b1 = bytes.get(offset);
				var b2 = bytes.get(offset + 1);
				var b3 = bytes.get(offset + 2);
				((b3 << 24) | (b2 << 16) | (b1 << 8)) >> 8;
			case 32: bytes.getInt32(offset) >> 16;
			case _: 0;
		}
	}

	static function writeSample(output:BytesOutput, sample:Int, bitsPerSample:Int)
	{
		sample = clamp(sample, -32768, 32767);

		output.writeByte(sample & 0xFF);
		output.writeByte((sample >> 8) & 0xFF);

		if (bitsPerSample == 24)
		{
			output.writeByte((sample >> 16) & 0xFF);
		}
		else if (bitsPerSample == 32)
		{
			output.writeByte(0);
			output.writeByte(0);
		}
	}

	static function clamp(value:Int, min:Int, max:Int):Int
	{
		return value < min ? min : (value > max ? max : value);
	}

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
}
