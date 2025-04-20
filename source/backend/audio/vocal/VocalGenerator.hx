package backend.audio.vocal;

import backend.song.*;
import backend.utils.SSMath;
import backend.utils.VocalUtil;
import haxe.io.Bytes;
import lime.media.AudioBuffer;
import openfl.media.Sound;
import sys.io.File;

using StringTools;

class VocalGenerator
{
	public var notes:Array<Note> = [];
	public var voiceBank:Voicebank;
	public var sound:Sound;

	public function new(notes:Array<Note>, voiceBank:Voicebank)
	{
		this.notes = notes;
		this.voiceBank = voiceBank;
	}

	function getInt16(bytes:Bytes, index:Int, littleEndian:Bool = true):Int
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

	function setInt16(bytes:Bytes, index:Int, value:Int, littleEndian:Bool = true)
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

	function copyBlock(source:Bytes, srcOffset:Int, dest:Bytes, destOffset:Int, length:Int)
	{
		for (i in 0...length)
			dest.set(destOffset + i, source.get(srcOffset + i));
	}

	public function generateVocalsFromParameterName(paramName:String = 'normal'):Bytes
	{
		var sampleRate:Int = voiceBank.sampleRate;
		var channels:Int = 1;
		var bitsPerSample:Int = 16;
		var bytesPerSample:Int = Std.int((bitsPerSample * channels) / 8);

		var totalDurationMs:Float = 0;
		for (note in notes)
			totalDurationMs = Math.max(totalDurationMs, note.time + note.duration);
		totalDurationMs += 100;

		var totalSamples:Int = Math.ceil(totalDurationMs / 1000 * sampleRate);
		var masterBytes:Bytes = Bytes.alloc(totalSamples * bytesPerSample);
		for (i in 0...masterBytes.length)
			masterBytes.set(i, 0);

		notes.sort(function(a, b) return Std.int(a.time - b.time));

		var noteSamples = new Map<Int, Bytes>();
		for (i in 0...notes.length)
		{
			var note = notes[i];
			if (note.phoneme == "rest")
				continue;
			var filePath:String = '';
			if (VocalUtil.isBreath(note.phoneme))
				filePath = voiceBank.samples.get(note.phoneme);
			else
				filePath = voiceBank.samples.get(paramName == 'normal' ? note.phoneme : '$paramName//${note.phoneme}');
			if (filePath != null)
			{
				var sampleBytes = ConvertFormat.convertWav(File.getBytes(filePath),
					VocalUtil.isVowel(note.phoneme) ? voiceBank.sampleStart : voiceBank.consonantSampleStart);
				noteSamples.set(i, sampleBytes.sub(44, sampleBytes.length - 44));
			}
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

			var fadeInSamples = Std.int((VocalUtil.isBreath(note.phoneme) ? 500 : (note.shortEnd ? 10 : 50)) / 1000 * sampleRate);
			var fadeOutSamples = Std.int((VocalUtil.isBreath(note.phoneme) ? 500 : (50)) / 1000 * sampleRate);

			// Get loop points (in samples)
			var loopStart = Std.int(voiceBank.sampleLoop / 1000 * sampleRate);
			var loopEnd = Std.int(voiceBank.sampleLoopEnd / 1000 * sampleRate);

			// Apply samples
			for (j in 0...noteDurationSamples)
			{
				var srcIndex = j + offsetAddition;
				var destOffset = (noteStartSample + j) * bytesPerSample;

				// Skip if destination is out of bounds
				if (destOffset + bytesPerSample > masterBytes.length)
					continue;

				// Apply loop logic
				if (srcIndex >= loopEnd)
				{
					// Calculate position within the loop
					var loopLength = loopEnd - loopStart;
					var loopPosition = (srcIndex - loopStart) % loopLength + loopStart;

					// Calculate if we need crossfading
					var halfLoopLength = Std.int(loopLength / 2);
					var positionInLoop = (srcIndex - loopStart) % loopLength;
					var needsCrossfade = positionInLoop >= halfLoopLength;

					if (needsCrossfade)
					{
						// Get position in first half of loop for crossfade source
						var crossfadePosition = loopStart + (positionInLoop - halfLoopLength);

						// Calculate crossfade ratio (0.0 to 1.0)
						var crossfadeRatio = (positionInLoop - halfLoopLength) / halfLoopLength;

						// Apply cosine-based crossfade
						var currentSample = 0;
						var nextLoopSample = 0;

						if (loopPosition * bytesPerSample < sampleData.length)
							currentSample = getInt16(sampleData, loopPosition * bytesPerSample, true);

						if (crossfadePosition * bytesPerSample < sampleData.length)
							nextLoopSample = getInt16(sampleData, crossfadePosition * bytesPerSample, true);

						// Smooth crossfade with cosine curve
						var fadeOutGain = Math.cos(Math.PI * crossfadeRatio / 2);
						var fadeInGain = Math.sin(Math.PI * crossfadeRatio / 2);

						var blendedSample = Std.int(currentSample * fadeOutGain + nextLoopSample * fadeInGain);

						// Apply regular fades if needed
						if (needsFadeIn && j < fadeInSamples && !crossfadedNotes.exists(noteIndex))
						{
							var gain = 0.5 * (1 - Math.cos(Math.PI * j / fadeInSamples));
							blendedSample = Std.int(blendedSample * gain);
						}
						else if (needsFadeOut && j >= noteDurationSamples - fadeOutSamples)
						{
							var fadeOutIndex = j - (noteDurationSamples - fadeOutSamples);
							var gain = 0.5 * (1 + Math.cos(Math.PI * fadeOutIndex / fadeOutSamples));
							blendedSample = Std.int(blendedSample * gain);
						}

						setInt16(masterBytes, destOffset, blendedSample, true);
					}
					else
					{
						// Just use the looped sample without crossfade
						var srcOffset = loopPosition * bytesPerSample;

						if (srcOffset < sampleData.length)
						{
							// Apply regular fades if needed
							if (needsFadeIn && j < fadeInSamples && !crossfadedNotes.exists(noteIndex))
							{
								var gain = 0.5 * (1 - Math.cos(Math.PI * j / fadeInSamples));
								var sample = getInt16(sampleData, srcOffset, true) * gain;
								setInt16(masterBytes, destOffset, Std.int(sample), true);
							}
							else if (needsFadeOut && j >= noteDurationSamples - fadeOutSamples)
							{
								var fadeOutIndex = j - (noteDurationSamples - fadeOutSamples);
								var gain = 0.5 * (1 + Math.cos(Math.PI * fadeOutIndex / fadeOutSamples));
								var sample = getInt16(sampleData, srcOffset, true) * gain;
								setInt16(masterBytes, destOffset, Std.int(sample), true);
							}
							else
							{
								copyBlock(sampleData, srcOffset, masterBytes, destOffset, bytesPerSample);
							}
						}
					}
				}
				else
				{
					// Regular (non-looped) sample processing
					var srcOffset = srcIndex * bytesPerSample;

					if (srcOffset < sampleData.length)
					{
						if (needsFadeIn && j < fadeInSamples && !crossfadedNotes.exists(noteIndex))
						{
							var gain = 0.5 * (1 - Math.cos(Math.PI * j / fadeInSamples));
							var sample = getInt16(sampleData, srcOffset, true) * gain;
							setInt16(masterBytes, destOffset, Std.int(sample), true);
						}
						else if (needsFadeOut && j >= noteDurationSamples - fadeOutSamples)
						{
							var fadeOutIndex = j - (noteDurationSamples - fadeOutSamples);
							var gain = 0.5 * (1 + Math.cos(Math.PI * fadeOutIndex / fadeOutSamples));
							var sample = getInt16(sampleData, srcOffset, true) * gain;
							setInt16(masterBytes, destOffset, Std.int(sample), true);
						}
						else
						{
							copyBlock(sampleData, srcOffset, masterBytes, destOffset, bytesPerSample);
						}
					}
				}
			}

			var hasNext = noteIndex < notes.length - 1;
			if (hasNext)
			{
				var nextNote = notes[noteIndex + 1];
				if (nextNote.phoneme == "rest" || !noteSamples.exists(noteIndex + 1))
					continue;

				var crossfadeSamples = Std.int(voiceBank.vowelBlendRatio / 1000 * sampleRate);

				if (!VocalUtil.isVowel(note.phoneme) && !VocalUtil.isVowel(nextNote.phoneme))
					crossfadeSamples = Std.int(voiceBank.consonantBlendRatio / 1000 * sampleRate);
				if (VocalUtil.isVowel(note.phoneme) && !VocalUtil.isVowel(nextNote.phoneme) && !(VocalUtil.isBreath(nextNote.phoneme)))
					crossfadeSamples = 0;

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

							if (masterPos + bytesPerSample <= masterBytes.length && j * bytesPerSample < loopedNext.length)
							{
								var fadeOutSample = 0.0;
								var fadeInSample = 0.0;

								var ratio = 0.5 * (1 - Math.cos(Math.PI * j / actualCrossfadeSamples));
								fadeOutSample = getInt16(masterBytes, masterPos, true) * (1 - ratio);
								fadeInSample = getInt16(loopedNext, j * bytesPerSample, true) * ratio;

								var blended = SSMath.clamp(Std.int(fadeOutSample + fadeInSample), -32768, 32767);
								setInt16(masterBytes, masterPos, blended, true);
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

			var noteStartSample:Int = Std.int(note.time / 1000 * sampleRate);
			var noteEndSample:Int = Std.int((note.time + note.duration) / 1000 * sampleRate);
			noteEndSample = cast Math.min(noteEndSample, totalSamples);

			var velocities:Array<SongValue> = [];

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

				switch (paramName)
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

				switch (paramName)
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
					if (destOffset + bytesPerSample <= masterBytes.length)
					{
						var sampleVal:Int = getInt16(masterBytes, destOffset, true);
						var newVal:Int = Std.int(SSMath.clamp(cast sampleVal * vel.value, -32768, 32767));
						setInt16(masterBytes, destOffset, newVal, true);
					}
				}
			}
		}
		return masterBytes;
	}

	function hasPitchData():Bool
	{
		for (note in notes)
		{
			if (note.pitches != null && note.pitches.length > 0)
				return true;
		}
		return false;
	}

	function createWavHeader(numSamples:Int, numChannels:Int, sampleRate:Int, bitsPerSample:Int):Bytes
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

	public function generateVocals():Sound
	{
		// merge everything together
		var finalSnd:Sound = null;

		var normal:Bytes = generateVocalsFromParameterName("normal");
		var mouth:Bytes = (voiceBank.mouth ? generateVocalsFromParameterName("mouth") : null);
		var breath:Bytes = (voiceBank.breaths ? generateVocalsFromParameterName("breaths") : null);
		var mouthBreath:Bytes = (voiceBank.mouthBreath ? generateVocalsFromParameterName("mouthBreath") : null);
		var power:Bytes = (voiceBank.power ? generateVocalsFromParameterName("power") : null);
		var mouthPower:Bytes = (voiceBank.mouthPower ? generateVocalsFromParameterName("mouthPower") : null);
		var soft:Bytes = (voiceBank.soft ? generateVocalsFromParameterName("soft") : null);
		var mouthSoft:Bytes = (voiceBank.mouthSoft ? generateVocalsFromParameterName("mouthSoft") : null);

		var channels:Int = 1;
		var bitsPerSample:Int = 16;
		var bytesPerSample:Int = Std.int((bitsPerSample * channels) / 8);

		var sounds:Array<Bytes> = [normal, mouth, breath, mouthBreath, power, mouthPower, soft, mouthSoft];
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

		var mergedBytes:Bytes = Bytes.alloc(maxLength);
		for (i in 0...mergedBytes.length)
			mergedBytes.set(i, 0);

		var numSamples:Int = Std.int(maxLength / bytesPerSample);
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

			setInt16(mergedBytes, i * bytesPerSample, mixedSample, true);
		}

		var totalSamples:Int = numSamples;
		// Pitch processing
		if (hasPitchData())
		{
			// convert mergedBytes to samples for simpler processing
			var samples:Array<Float> = [];
			for (i in 0...totalSamples)
			{
				var offset = i * bytesPerSample;
				if (offset + bytesPerSample <= mergedBytes.length)
					samples.push(getInt16(mergedBytes, offset, true) / 32768.0);
				else
					samples.push(0.0);
			}
			// process pitch modulation
			var pitches:Array<SongValue> = [];
			for (note in notes)
			{
				for (pitch in note.pitches)
					pitches.push({time: pitch.time, value: pitch.value});
			}
			// var stretchedSamples = TimeStretcher.processInSemitones(samples, 44100, pitches);
			// var pitchedSamples = PitchShifter.process(stretchedSamples, 44100, pitches);
			// var formantCorrectedSamples = FormantCorrector.process(pitchedSamples, 44100, pitches);
			var formantCorrectedSamples = samples;

			// convert back to bytes
			mergedBytes = Bytes.alloc(cast formantCorrectedSamples.length * bytesPerSample);
			for (i in 0...formantCorrectedSamples.length)
			{
				var sample = Std.int(SSMath.clamp(cast formantCorrectedSamples[i] * 32767, -32768, 32767));
				setInt16(mergedBytes, i * bytesPerSample, sample, true);
			}
		}
		var wavHeader:Bytes = createWavHeader(totalSamples, channels, voiceBank.sampleRate, bitsPerSample);
		var complete:Bytes = Bytes.alloc(wavHeader.length + mergedBytes.length);
		complete.blit(0, wavHeader, 0, wavHeader.length);
		complete.blit(wavHeader.length, mergedBytes, 0, mergedBytes.length);

		File.saveBytes('vocals.wav', complete);
		finalSnd = Sound.fromAudioBuffer(AudioBuffer.fromBytes(complete));
		sound = finalSnd;
		return finalSnd;
	}
}
