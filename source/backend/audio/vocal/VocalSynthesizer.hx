package backend.audio.vocal;

import backend.config.GlobalConfig;
import backend.data.*;
import backend.utils.AudioUtil;
import backend.utils.CopyUtil;
import backend.utils.SSMath;
import backend.utils.VocalUtil;
import haxe.Timer;
import haxe.io.Bytes;
import lime.media.AudioBuffer;
import openfl.events.Event;
import openfl.media.Sound;
import sys.FileSystem;
import sys.io.File;

using StringTools;

class VocalSynthesizer
{
	public static var sound(get, null):Sound;
	public static var bytes:Bytes;

	public var curParamSound(get, null):Sound;
	public var curParamBytes:Bytes;

	public static var synthesized:Bool = false;

	public var batchedResampler:ResamplerBatched;
	public var complete:Bool = false;

	static var threadedSynthesizer:VocalSynthesizerThreaded;
	static var bitsPerSample:Int = 16;
	static var bytesPerSample:Int = 2; // the result of (bitsPerSample * channels) / 8
	static var timer:Timer;

	var sampleIndexMap:Map<Int, Int>;
	var totalSamples:Int;
	var noteSamples:Map<Int, Bytes> = new Map();

	static function get_sound():Sound
		return Sound.fromAudioBuffer(AudioBuffer.fromBytes(bytes));

	function get_curParamSound():Sound
		return Sound.fromAudioBuffer(AudioBuffer.fromBytes(curParamBytes));

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

	static function copyBlock(source:Bytes, srcOffset:Int, dest:Bytes, destOffset:Int, length:Int)
	{
		for (i in 0...length)
			dest.set(destOffset + i, source.get(srcOffset + i));
	}

	public function new() {}

	public function synthesizeVocalsFromParameterName(paramName:String = 'normal', _notes:Array<Note>, voiceBank:Voicebank, resampMode:Bool)
	{
		var notes = CopyUtil.copyArray(_notes);
		noteSamples = new Map();
		var sampleRate = 44100;
		var totalDurationMs:Float = 0;
		for (note in notes)
			totalDurationMs = Math.max(totalDurationMs, note.time + note.duration);
		totalDurationMs += 100;

		totalSamples = Math.ceil(totalDurationMs / 1000 * sampleRate);
		curParamBytes = Bytes.alloc(totalSamples * bytesPerSample);
		for (i in 0...curParamBytes.length)
			curParamBytes.set(i, 0);

		notes.sort(function(a, b) return Std.int(a.time - b.time));

		var sampleSets:Array<
			{
				samples:Array<Float>,
				esperPath:String,
				params:String,
				resamplerName:String,
				resampler:String,
				frqPath:String,
				llsmPath:String,
				llsmTmpPath:String
			}> = [];
		sampleIndexMap = new Map();
		for (i in 0...notes.length)
		{
			var note = notes[i];

			var filePath:String = '';
			if (VocalUtil.isBreath(note.phoneme))
				filePath = voiceBank.samples.get(note.phoneme);
			else
				filePath = voiceBank.samples.get(paramName == 'normal' ? note.phoneme : '$paramName//${note.phoneme}');

			if (filePath != '')
			{
				var sampleBytes = ConvertFormat.convertWav(File.getBytes(filePath),
					(VocalUtil.isVowel(note.phoneme) ? voiceBank.sampleStart - 30 : voiceBank.consonantSampleStart - 30) + note.sampleStartOffset);
				var snd = Sound.fromAudioBuffer(AudioBuffer.fromBytes(sampleBytes));
				var targetLen = note.duration + 30; // avoid the fade out created by the resampler
				var sndLen = snd.length + 30;
				var finalLen:Int = cast sndLen > targetLen ? sndLen : targetLen;
				var mappedPower = Math.round((note.powerValue - 1) * 100);
				var mappedBreathiness = Math.round((note.breathinessValue - note.tension / 100) * 100);
				inline function resampParams():String
					return 'C4 100 "pstb100dyn${mappedPower}int${mappedPower}bre${note.atonal ? 100 : mappedBreathiness}rgh${note.roughness}" 0 $finalLen 0 0 100 0 T120 ${PitchBendEncoder.encodePitchBend(note.pitches, finalLen)}';

				// Possible file paths for ESPER-Utau and MoreSampler resamplers
				var frqPath = './${voiceBank.fileName}/$paramName/${note.phoneme}_wav.frq';
				if (!FileSystem.exists(frqPath))
					frqPath = '';
				var esperPath = './${voiceBank.fileName}/$paramName/${note.phoneme}.wav.esp';
				if (!FileSystem.exists(esperPath))
					esperPath = '';
				var llsmPath = './${voiceBank.fileName}/$paramName/${note.phoneme}.wav.llsm';
				if (!FileSystem.exists(llsmPath))
					llsmPath = '';
				var llsmTmpPath = './${voiceBank.fileName}/$paramName/${note.phoneme}.wav.llsm.tmp';
				if (!FileSystem.exists(llsmTmpPath))
					llsmTmpPath = '';
				sampleSets.push({
					samples: AudioUtil.pcm16BytesToFloatArray(sampleBytes),
					resamplerName: GlobalConfig.resamplerName,
					resampler: GlobalConfig.resampler,
					frqPath: frqPath,
					esperPath: esperPath,
					llsmPath: llsmPath,
					llsmTmpPath: llsmTmpPath,
					params: resampMode ? resampParams() : 'C4 100 "pstb100bre${note.atonal ? 100 : -(note.tension)}rgh${note.roughness}" 0 $finalLen 0 0 100 0 T120 ${PitchBendEncoder.encodePitchBend(note.pitches, note.duration)}'
				});
				sampleIndexMap.set(i, sampleSets.length - 1);
			}
		}

		batchedResampler = new ResamplerBatched(sampleSets, paramName);
		batchedResampler.runBatches();
		// skip 30ms ahead to avoid the pop created by ESPER-Utau
		var bytesToSkip = Math.floor(sampleRate * 0.030 * 2);
		for (i in sampleIndexMap.keys())
		{
			var outputIndex = sampleIndexMap.get(i);
			var finalSamples = AudioUtil.floatArrayToPCM16Bytes(batchedResampler.outputSampleSets[outputIndex]);
			var startIndex = 44 + bytesToSkip;
			var lengthToExtract = finalSamples.length - startIndex - bytesToSkip;
			if (lengthToExtract < 0)
				lengthToExtract = 0;
			noteSamples.set(i, finalSamples.sub(startIndex, lengthToExtract));
		}
		var noteOffsets = new Map<Int, Int>();
		var crossfadedNotes = new Map<Int, Bool>();
		for (noteIndex in 0...notes.length)
		{
			var note = notes[noteIndex];
			if (note.phoneme == "rest" || !noteSamples.exists(noteIndex))
				continue;

			var sampleData = noteSamples.get(noteIndex);
			var noteStartSample = Std.int(note.time / 1000 * sampleRate);
			var noteDurationSamples = Std.int(note.duration / 1000 * sampleRate);

			var hasPrev = noteIndex > 0;
			var prevNote = hasPrev ? notes[noteIndex - 1] : null;

			var hasNext = noteIndex < notes.length - 1;
			var nextNote = hasNext ? notes[noteIndex + 1] : null;

			var needsFadeIn = false;

			if (!hasPrev
				|| (hasPrev && (prevNote.time + prevNote.duration < note.time))
				|| (VocalUtil.isBreath(note.phoneme))
				|| (VocalUtil.isBreath(prevNote.phoneme)))
			{
				needsFadeIn = true;
			}

			var needsFadeOut = false;

			if (!hasNext
				|| (hasNext && (note.time + note.duration < nextNote.time + 100))
				|| (VocalUtil.isBreath(note.phoneme))
				|| (VocalUtil.isBreath(nextNote.phoneme)))
			{
				needsFadeOut = true;
			}

			var offsetAddition = noteOffsets.exists(noteIndex) ? noteOffsets.get(noteIndex) : 0;

			var fadeInSamples = Std.int((VocalUtil.isBreath(note.phoneme) ? 500 : 50) / 1000 * sampleRate);
			var fadeOutSamples = fadeInSamples;

			// Apply samples
			for (j in 0...noteDurationSamples)
			{
				var srcIndex = j + offsetAddition;
				var destOffset = (noteStartSample + j) * bytesPerSample;

				// Skip if destination is out of bounds
				if (destOffset + bytesPerSample > curParamBytes.length)
					continue;

				// Regular sample processing
				var srcOffset = srcIndex * bytesPerSample;

				if (srcOffset < sampleData.length)
				{
					if (needsFadeIn && j < fadeInSamples && !crossfadedNotes.exists(noteIndex))
					{
						var gain = 0.5 * (1 - Math.cos(Math.PI * j / fadeInSamples));
						var sample = getInt16(sampleData, srcOffset, true) * gain;
						setInt16(curParamBytes, destOffset, Std.int(sample), true);
					}
					else if (needsFadeOut && j >= noteDurationSamples - fadeOutSamples)
					{
						var fadeOutIndex = j - (noteDurationSamples - fadeOutSamples);
						var gain = 0.5 * (1 + Math.cos(Math.PI * fadeOutIndex / fadeOutSamples));
						var sample = getInt16(sampleData, srcOffset, true) * gain;
						setInt16(curParamBytes, destOffset, Std.int(sample), true);
					}
					else
					{
						copyBlock(sampleData, srcOffset, curParamBytes, destOffset, bytesPerSample);
					}
				}
			}

			var hasNext = noteIndex < notes.length - 1;
			if (hasNext)
			{
				var nextNote = notes[noteIndex + 1];
				if (nextNote.phoneme == "rest" || !noteSamples.exists(noteIndex + 1))
					continue;

				var crossfadeSamples = Std.int(note.blendRatio / 1000 * sampleRate);
				var offsetNext = 0;
				noteOffsets.set(noteIndex + 1, crossfadeSamples);
				crossfadedNotes.set(noteIndex + 1, true);

				// only apply crossfade if notes are touching
				if (Math.abs((note.time + note.duration) - nextNote.time) < 1)
				{
					var nextSampleData = noteSamples.get(noteIndex + 1).sub(0, crossfadeSamples * bytesPerSample);
					var nextStartSample = Std.int(nextNote.time / 1000 * sampleRate);

					var blendStart = Math.min(nextStartSample - crossfadeSamples, noteStartSample + noteDurationSamples - crossfadeSamples);
					if (blendStart < 0)
						blendStart = 0;

					if (offsetNext * bytesPerSample < nextSampleData.length)
					{
						var availableSamples:Int = cast Math.floor((nextSampleData.length - offsetNext * bytesPerSample) / bytesPerSample);
						var actualCrossfadeSamples:Int = cast Math.min(crossfadeSamples, availableSamples);
						var loopedNext = nextSampleData.sub(offsetNext * bytesPerSample, actualCrossfadeSamples * bytesPerSample);

						for (j in 0...actualCrossfadeSamples)
						{
							var masterPos:Int = cast(blendStart + j) * bytesPerSample;

							if (masterPos + bytesPerSample <= curParamBytes.length && j * bytesPerSample < loopedNext.length)
							{
								var fadeOutSample = 0.0;
								var fadeInSample = 0.0;

								var ratio = 0.5 * (1 - Math.cos(Math.PI * j / actualCrossfadeSamples));
								fadeOutSample = getInt16(curParamBytes, masterPos, true) * (1 - ratio);
								fadeInSample = getInt16(loopedNext, j * bytesPerSample, true) * ratio;

								var blended = SSMath.clamp(Std.int(fadeOutSample + fadeInSample), -32768, 32767);
								setInt16(curParamBytes, masterPos, blended, true);
							}
						}
					}
				}
			}
		}

		// Second pass: note paramaters/velocity
		for (noteIndex in 0...notes.length)
		{
			var note = notes[noteIndex];
			if (note.phoneme == "rest")
				continue;

			var sampleRate = 44100;
			var noteStartSample:Int = Std.int(note.time / 1000 * sampleRate);
			var noteEndSample:Int = Std.int((note.time + note.duration) / 1000 * sampleRate);
			noteEndSample = cast Math.min(noteEndSample, totalSamples);

			var velocities:Array<SongValue> = [];

			if (resampMode)
			{
				velocities = note.velocities;
			}
			else
			{
				for (p in note.power)
				{
					var time = p.time;

					var velocityParam:SongValue = {value: 1.0, time: time};
					for (v in note.velocities)
					{
						if (v.time == time)
							velocityParam = v;
						else
							break;
					}

					var mouthParam:SongValue = {value: 1.0, time: time};
					for (m in note.mouth)
					{
						if (m.time == time)
							mouthParam = m;
						else
							break;
					}

					var softness = Math.max(0, 1 - p.value);
					var normal = Math.max(0, 1 - Math.abs(p.value - 1));
					var powerful = Math.max(0, p.value - 1);

					var finalVelocity:Float = 0.0;

					// File ext is also the parameter name
					switch (batchedResampler.fileExt)
					{
						case "soft":
							finalVelocity = softness * velocityParam.value;
						case "mouthSoft":
							finalVelocity = softness * velocityParam.value * mouthParam.value;
						case "normal":
							finalVelocity = normal * velocityParam.value;
						case "mouth":
							finalVelocity = normal * velocityParam.value * mouthParam.value;
						case "power":
							finalVelocity = powerful * velocityParam.value;
						case "mouthPower":
							finalVelocity = powerful * velocityParam.value * mouthParam.value;
						default:
							continue;
					}

					velocities.push({value: finalVelocity, time: time});
				}

				// for breathiness parameter
				for (b in note.breathiness)
				{
					var time = b.time;

					var velocityParam:SongValue = {value: 1.0, time: time};
					for (v in note.velocities)
					{
						if (v.time == time)
							velocityParam = v;
						else
							break;
					}

					var mouthParam:SongValue = {value: 1.0, time: time};
					for (m in note.mouth)
					{
						if (m.time == time)
							mouthParam = m;
						else
							break;
					}

					var breathValue = Math.max(0, b.value);

					var finalVelocity:Float = 0.0;

					switch (batchedResampler.fileExt)
					{
						case "breaths":
							finalVelocity = breathValue * velocityParam.value;
						case "mouthBreath":
							finalVelocity = breathValue * velocityParam.value * mouthParam.value;
						default:
							continue;
					}

					velocities.push({value: finalVelocity, time: time});
				}
			}

			for (v in 0...velocities.length)
			{
				var vel:SongValue = velocities[v];
				var segStartMs:Float = vel.time;
				var segEndMs:Float = (v < velocities.length - 1) ? velocities[v + 1].time : note.duration;

				var segStartSample:Int = noteStartSample + Std.int(segStartMs / 1000 * sampleRate);
				var segEndSample:Int = noteStartSample + Std.int(segEndMs / 1000 * sampleRate);
				segEndSample = cast Math.min(segEndSample, noteEndSample);

				for (i in segStartSample...segEndSample)
				{
					var destOffset:Int = i * bytesPerSample;
					if (destOffset + bytesPerSample <= curParamBytes.length)
					{
						var sampleVal:Int = getInt16(curParamBytes, destOffset, true);
						var newVal:Int = Std.int(SSMath.clamp(cast sampleVal * vel.value, -32768, 32767));
						setInt16(curParamBytes, destOffset, newVal, true);
					}
				}
			}
		}
		complete = true;
	}

	static function waitForVocals()
	{
		if (threadedSynthesizer.completed)
		{
			var res:Bytes = null;
			var numSamples:Int = 0;
			if (threadedSynthesizer.resampMode)
			{
				numSamples = Std.int(threadedSynthesizer.output.get('normal').length / bytesPerSample);
				res = Bytes.alloc(threadedSynthesizer.output.get('normal').length);
				res.blit(0, threadedSynthesizer.output.get('normal'), 0, threadedSynthesizer.output.get('normal').length);
			}
			else
			{
				var sounds:Array<Bytes> = [
					threadedSynthesizer.output.get('normal'),
					threadedSynthesizer.output.get('mouth'),
					threadedSynthesizer.output.get('breath'),
					threadedSynthesizer.output.get('mouthBreath'),
					threadedSynthesizer.output.get('power'),
					threadedSynthesizer.output.get('mouthPower'),
					threadedSynthesizer.output.get('soft'),
					threadedSynthesizer.output.get('mouthSoft')
				];
				var soundNames:Array<String> = [
					"normal",
					"mouth",
					"breaths",
					"mouthBreath",
					"power",
					"mouthPower",
					"soft",
					"mouthSoft"
				];
				var i = 0;
				while (i < sounds.length)
				{
					if (sounds[i] == null)
					{
						sounds.splice(i, 1);
						soundNames.splice(i, 1);
					}
					else
						i++;
				}
				var maxLength:Int = 0;
				for (sound in sounds)
				{
					if (sound.length > maxLength)
						maxLength = sound.length;
				}
				res = Bytes.alloc(maxLength);
				for (i in 0...res.length)
					res.set(i, 0);
				numSamples = Std.int(maxLength / bytesPerSample);
				for (i in 0...numSamples)
				{
					var breathSampleSum:Int = 0;
					var breathSampleCount:Int = 0;
					for (j in 0...sounds.length)
					{
						if (soundNames[j] == "breaths" || soundNames[j] == "mouthBreath")
						{
							var offset:Int = i * bytesPerSample;
							if (offset + bytesPerSample <= sounds[j].length)
							{
								var sample = getInt16(sounds[j], offset, true);
								if (Math.abs(sample) > 0)
								{
									breathSampleSum += cast Math.abs(sample);
									breathSampleCount++;
								}
							}
						}
					}
					var breathIntensity:Float = 0.0;
					if (breathSampleCount > 0)
						breathIntensity = Math.min(1.0, (breathSampleSum / breathSampleCount) / 16384.0);
					var mixedSample:Int = 0;
					var nonBreathSampleCount:Int = 0;
					var nonBreathSampleSum:Int = 0;
					var breathOnlySampleSum:Int = 0;
					for (j in 0...sounds.length)
					{
						var offset:Int = i * bytesPerSample;
						if (offset + bytesPerSample <= sounds[j].length)
						{
							var sample = getInt16(sounds[j], offset, true);
							if (soundNames[j] == "breaths" || soundNames[j] == "mouthBreath")
								breathOnlySampleSum += sample;
							else
							{
								var attenuationFactor:Float = 1.0 - breathIntensity;
								nonBreathSampleSum += Std.int(sample * attenuationFactor);
								if (Math.abs(sample) > 0)
									nonBreathSampleCount++;
							}
						}
					}
					mixedSample = breathOnlySampleSum + nonBreathSampleSum;
					if (Math.abs(mixedSample) > 32767)
						mixedSample = (mixedSample > 0) ? 32767 : -32768;
					setInt16(res, i * bytesPerSample, mixedSample, true);
				}
			}

			var wavHeader:Bytes = AudioUtil.createWavHeader(numSamples, 1, 44100, bitsPerSample);
			var completeBytes:Bytes = Bytes.alloc(wavHeader.length + res.length);
			completeBytes.blit(0, wavHeader, 0, wavHeader.length);
			completeBytes.blit(wavHeader.length, res, 0, res.length);
			#if debug File.saveBytes('vocals.wav', completeBytes); #end
			bytes = completeBytes;
			timer.stop();
			synthesized = true;
		}
	}

	public static function synthesizeVocals(notes:Array<Note>, voiceBank:Voicebank, resampMode:Bool)
	{
		synthesized = false;
		threadedSynthesizer = new VocalSynthesizerThreaded(notes, voiceBank, resampMode);
		threadedSynthesizer.runBatches();
		timer = new Timer(0.001);
		timer.run = waitForVocals;
	}
}
