package backend.audio.kenetix;

import backend.audio.areo.Areo;
import backend.audio.formavox.FormaVox;
import backend.audio.formavox.FormaVoxValue;
import backend.audio.formavox.LPCFilter;
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
	public var curParamSound(get, null):Sound;
	public var curParamBytes:Bytes;

	public var batchedResampler:ResamplerBatched;
	public var complete:Bool = false;

	@:allow(backend.audio.kenetix.Kenetix)
	static var sound(get, null):Sound;
	@:allow(backend.audio.kenetix.Kenetix)
	static var bytes:Bytes;
	@:allow(backend.audio.kenetix.Kenetix)
	static var synthesized:Bool = false;
	@:allow(backend.audio.kenetix.Kenetix)
	static var threadedSynthesizer:VocalSynthesizerThreaded;
	@:allow(backend.audio.kenetix.Kenetix)
	static var timer:Timer;
	static var bitsPerSample:Int = 16;
	static var bytesPerSample:Int = 2;

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
				note:Note,
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
			if (!VocalUtil.isBreath(note.phoneme))
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

				// possible file paths for ESPER-Utau, F2Resamp and MoreSampler resamplers
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
					note: note,
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
			var finalSamples = AudioUtil.floatArrayToPCM16Bytes(FormaVox.processSamples(batchedResampler.outputSampleSets[outputIndex].samples,
				batchedResampler.outputSampleSets[outputIndex].note.formants, sampleRate));
			var startIndex = 44 + bytesToSkip;
			var lengthToExtract = finalSamples.length - startIndex - bytesToSkip;
			if (lengthToExtract < 0)
				lengthToExtract = 0;
			noteSamples.set(i, finalSamples.sub(startIndex, lengthToExtract));
		}

		// First Pass: note sequencing
		var noteOffsets = new Map<Int, Int>();
		var crossfadedNotes = new Map<Int, Bool>();
		for (noteIndex in 0...notes.length)
		{
			var note = notes[noteIndex];
			if (!noteSamples.exists(noteIndex))
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

			for (j in 0...noteDurationSamples)
			{
				var srcIndex = j + offsetAddition;
				var destOffset = (noteStartSample + j) * bytesPerSample;

				if (destOffset + bytesPerSample > curParamBytes.length)
					continue;

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

			if (hasNext)
			{
				var nextNote = notes[noteIndex + 1];
				if (!noteSamples.exists(noteIndex + 1))
					continue;

				var crossfadeSamples = Std.int(note.blendRatio / 1000 * sampleRate);
				var offsetNext = 0;
				noteOffsets.set(noteIndex + 1, crossfadeSamples);
				crossfadedNotes.set(noteIndex + 1, true);

				if (Math.abs((note.time + note.duration) - nextNote.time) < 1)
				{
					var nextSampleData = noteSamples.get(noteIndex + 1);
					var nextStartSample = Std.int(nextNote.time / 1000 * sampleRate);

					var blendStart = Math.min(nextStartSample - crossfadeSamples, noteStartSample + noteDurationSamples - crossfadeSamples);
					if (blendStart < 0)
						blendStart = 0;

					if (offsetNext * bytesPerSample < nextSampleData.length)
					{
						var availableSamples:Int = cast Math.floor((nextSampleData.length - offsetNext * bytesPerSample) / bytesPerSample);
						var actualCrossfadeSamples:Int = cast Math.min(crossfadeSamples, availableSamples);
						var loopedNext = nextSampleData.sub(offsetNext * bytesPerSample, actualCrossfadeSamples * bytesPerSample);

						var curProfile = FormaVox.getProfile(note.phoneme);
						var nextProfile = FormaVox.getProfile(nextNote.phoneme);

						if (!VocalUtil.isVowel(note.phoneme) && !VocalUtil.isBreath(note.phoneme))
							curProfile = FormaVox.getProfile(note.phoneme.charAt(note.phoneme.length - 1));
						if (!VocalUtil.isVowel(nextNote.phoneme) && !VocalUtil.isBreath(nextNote.phoneme))
							nextProfile = FormaVox.getProfile(nextNote.phoneme.charAt(nextNote.phoneme.length - 1));

						var filter = new LPCFilter(curProfile, sampleRate);
						var prevSample = getInt16(curParamBytes, cast Math.max(0, (blendStart - 1)) * bytesPerSample, true) / 32768.0;

						for (j in 0...actualCrossfadeSamples)
						{
							var masterPos:Int = cast(blendStart + j) * bytesPerSample;

							if (masterPos + bytesPerSample <= curParamBytes.length && j * bytesPerSample < loopedNext.length)
							{
								var ratio = j / actualCrossfadeSamples;

								var rawOut = getInt16(curParamBytes, masterPos, true);
								var rawIn = getInt16(loopedNext, j * bytesPerSample, true);

								// Crossfade
								var blendedSample = rawOut * (1 - ratio) + rawIn * ratio;

								// Interpolate formants and update the filter
								var interpFormants = {
									f1: curProfile.f1 * (1 - ratio) + nextProfile.f1 * ratio,
									f2: curProfile.f2 * (1 - ratio) + nextProfile.f2 * ratio,
									f3: curProfile.f3 * (1 - ratio) + nextProfile.f3 * ratio
								};

								filter.updateProfile(interpFormants, sampleRate);

								// Phase alignment smoothing (fade from last sample)
								var smoothBlend = prevSample * (1 - ratio) + (blendedSample / 32768.0) * ratio;
								var filtered = filter.process(smoothBlend);
								prevSample = smoothBlend;

								var finalSample = SSMath.clamp(Std.int(filtered * 32768), -32768, 32767);
								setInt16(curParamBytes, masterPos, finalSample, true);
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
			if (!noteSamples.exists(noteIndex))
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

					var softness = Math.max(0, 1 - p.value);
					var normal = Math.max(0, 1 - Math.abs(p.value - 1));
					var powerful = Math.max(0, p.value - 1);

					var finalVelocity:Float = 0.0;

					// file ext is also the parameter name
					switch (batchedResampler.fileExt)
					{
						case "soft":
							finalVelocity = softness * velocityParam.value;
						case "normal":
							finalVelocity = normal * velocityParam.value;
						case "power":
							finalVelocity = powerful * velocityParam.value;
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

					var breathValue = Math.max(0, b.value);

					var finalVelocity:Float = 0.0;

					switch (batchedResampler.fileExt)
					{
						case "breaths":
							finalVelocity = breathValue * velocityParam.value;
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

		// Third pass: breathiness
		if (voiceBank.samples.get('b1') != null)
		{
			var regions = Areo.groupBreathRegions(notes);
			for (regionIndex in 0...regions.length)
			{
				var region = regions[regionIndex];
				var rawBreath = ConvertFormat.convertWav(File.getBytes(voiceBank.samples.get('b1')), voiceBank.sampleStart);
				var breathBytesRaw = rawBreath.sub(44, rawBreath.length - 44);
				var breathLen = Std.int(breathBytesRaw.length / bytesPerSample);
				var regionStartSample = Std.int(region.startTime / 1000 * sampleRate);
				var regionEndSample = Std.int(region.endTime / 1000 * sampleRate);
				var regionDurationMs = region.endTime - region.startTime;
				var totalRegionSamples = Std.int(regionDurationMs / 1000 * sampleRate);
				var loopedBreathSamples:Array<Int> = [];
				var crossfadeLen = Std.int(breathLen / 2);
				for (i in 0...totalRegionSamples)
				{
					var breathIndex = i % breathLen;
					var breath:Int;
					var crossfadeStart = breathLen - crossfadeLen;
					if (breathIndex >= crossfadeStart)
					{
						var fadeT = (breathIndex - crossfadeStart) / crossfadeLen;
						var offsetA = breathIndex * bytesPerSample;
						var offsetB = (breathIndex - crossfadeStart) * bytesPerSample;
						var a = getInt16(breathBytesRaw, offsetA, true);
						var b = getInt16(breathBytesRaw, offsetB, true);
						breath = Std.int(a * (1 - fadeT) + b * fadeT);
					}
					else
					{
						var breathOffset = breathIndex * bytesPerSample;
						breath = getInt16(breathBytesRaw, breathOffset, true);
					}
					loopedBreathSamples.push(breath & 0xFF);
					loopedBreathSamples.push((breath >> 8) & 0xFF);
				}

				var loopedBreathFloats:Array<Float> = [];
				for (i in 0...Std.int(loopedBreathSamples.length / 2))
				{
					var lo = loopedBreathSamples[i * 2];
					var hi = loopedBreathSamples[i * 2 + 1];
					var sample:Int = (hi << 8) | (lo & 0xFF);
					if (sample > 32767)
						sample -= 65536;
					loopedBreathFloats.push(sample / 32768.0);
				}

				var fadeInRatio = 0.03;
				var fadeOutRatio = 0.03;
				if (regionIndex + 1 < regions.length)
				{
					var nextRegion = regions[regionIndex + 1];
					if (nextRegion.notes.length > 0 && VocalUtil.isPlosive(nextRegion.notes[0].phoneme))
					{
						fadeOutRatio = 0.005;
					}
				}
				var fadeInSamples = Std.int(fadeInRatio * regionDurationMs);
				var fadeOutSamples = Std.int(fadeOutRatio * regionDurationMs);
				var breathiness:Array<SongValue> = [];
				for (i in 0...regionDurationMs)
				{
					var base = 1;
					var value = base;
					if (i < fadeInSamples)
						value = cast base * (i / fadeInSamples);
					else if (i >= regionDurationMs - fadeOutSamples)
						value = cast base * ((regionDurationMs - i) / fadeOutSamples);
					breathiness.push({time: i, value: value});
				}
				var breathBytes = ConvertFormat.convertWav(AudioUtil.floatArrayToWav(Areo.renderBreath(loopedBreathFloats, breathiness, sampleRate)));
				var breathData = breathBytes.sub(44, breathBytes.length - 44);
				for (i in regionStartSample...regionEndSample)
				{
					var destOffset = i * bytesPerSample;
					var breathOffset = (i - regionStartSample) * bytesPerSample;
					if (breathOffset + bytesPerSample <= breathData.length && destOffset + bytesPerSample <= curParamBytes.length)
					{
						var sample:Int = getInt16(curParamBytes, destOffset, true);
						var breath:Int = Std.int(getInt16(breathData, breathOffset, true));
						var finalSample:Int = Std.int(SSMath.clamp(sample + breath, -32768, 32767));
						setInt16(curParamBytes, destOffset, finalSample, true);
					}
				}
			}
		}
		complete = true;
	}

	@:allow(backend.audio.kenetix.Kenetix)
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
					threadedSynthesizer.output.get('breath'),
					threadedSynthesizer.output.get('power'),
					threadedSynthesizer.output.get('soft')
				];
				var soundNames:Array<String> = ["normal", "breaths", "power", "soft",];
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
						if (soundNames[j] == "breaths")
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
							if (soundNames[j] == "breaths")
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
}
