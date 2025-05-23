package backend.audio.vocal;

import backend.song.*;
import backend.utils.AudioUtil;
import backend.utils.SSMath;
import backend.utils.VocalUtil;
import haxe.io.Bytes;
import lime.media.AudioBuffer;
import openfl.events.Event;
import openfl.media.Sound;
import sys.io.File;

using StringTools;

class VocalGenerator
{
	public var notes:Array<Note> = [];
	public var esperMode:Bool;
	public var voiceBank:Voicebank;
	public var sound:Sound;

	public function new(notes:Array<Note>, voiceBank:Voicebank, ?esperMode:Bool = false)
	{
		this.notes = notes;
		this.voiceBank = voiceBank;
		this.esperMode = esperMode;
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

	var sampleRate:Int;
	var channels:Int = 1;
	var bitsPerSample:Int = 16;
	var bytesPerSample:Int;
	var threadedEsper:ESPERUtauThreaded;
	var sampleIndexMap:Map<Int, Int>;
	var masterBytes:Bytes;
	var totalSamples:Int;
	var paramName:String;
	var generated:Bool = false;
	var noteSamples:Map<Int, Bytes> = new Map();

	public function generateVocalsFromParameterName(paramName:String = 'normal')
	{
		noteSamples = new Map();
		this.paramName = paramName;
		generated = false;
		sampleRate = voiceBank.sampleRate;
		bytesPerSample = Std.int((bitsPerSample * channels) / 8);
		var totalDurationMs:Float = 0;
		for (note in notes)
			totalDurationMs = Math.max(totalDurationMs, note.time + note.duration);
		totalDurationMs += 100;

		totalSamples = Math.ceil(totalDurationMs / 1000 * sampleRate);
		masterBytes = Bytes.alloc(totalSamples * bytesPerSample);
		for (i in 0...masterBytes.length)
			masterBytes.set(i, 0);

		notes.sort(function(a, b) return Std.int(a.time - b.time));

		var sampleSets:Array<{samples:Array<Float>, params:String}> = [];
		sampleIndexMap = new Map();
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
				// no way there is gonna be an entry at index 2147483640. That's pushing to the 32 bit integer limit...
				var mappedPower = Math.round(note.power[2147483640] != null ? (note.power[2147483640].value - 1) * 100 : 0);
				var mappedBreathiness = Math.round(((note.breathiness[2147483640] != null ? note.breathiness[2147483640].value : 0) - note.tension) * 100);
				inline function esperParams():String
					return 'C4 100 "pstb100bri${mappedPower}dyn${mappedPower}bre${mappedBreathiness}rgh${note.roughness * 100}" 0 ${note.duration} 0 0 100 0 T120 ${PitchBendEncoder.encodePitchBend(note.pitches)}';

				sampleSets.push({
					samples: AudioUtil.pcm16BytesToFloatArray(sampleBytes),
					params: esperMode ? esperParams() : 'C4 100 "pstb100bre${- (note.tension * 100)}rgh${note.roughness * 100}" 0 ${note.duration} 0 0 100 0 T120 ${PitchBendEncoder.encodePitchBend(note.pitches)}'
				});
				sampleIndexMap.set(i, sampleSets.length - 1);
			}
		}

		threadedEsper = new ESPERUtauThreaded(sampleSets);
		threadedEsper.runBatches();
		FlxG.stage.addEventListener(Event.ENTER_FRAME, postEsper);
	}

	function postEsper(_)
	{
		if (threadedEsper.completed)
		{
			FlxG.stage.removeEventListener(Event.ENTER_FRAME, postEsper);

			for (i in sampleIndexMap.keys())
			{
				var outputIndex = sampleIndexMap.get(i);
				var finalSamples = AudioUtil.floatArrayToPCM16Bytes(threadedEsper.outputSampleSets[outputIndex]);
				noteSamples.set(i, finalSamples.sub(44, finalSamples.length - 44)); // skip WAV header
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

				// Apply samples
				for (j in 0...noteDurationSamples)
				{
					var srcIndex = j + offsetAddition;
					var destOffset = (noteStartSample + j) * bytesPerSample;

					// Skip if destination is out of bounds
					if (destOffset + bytesPerSample > masterBytes.length)
						continue;

					// Regular sample processing
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

				if (esperMode)
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
			generated = true;
		}
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

	var generating = '';
	var normal:Bytes;
	var mouth:Bytes;
	var breath:Bytes;
	var mouthBreath:Bytes;
	var power:Bytes;
	var mouthPower:Bytes;
	var soft:Bytes;
	var mouthSoft:Bytes;
	var completed:Bool = false;

	function waitForVocals(_)
	{
		var res:Bytes = null;
		var numSamples:Int = 0;
		if (esperMode)
		{
			switch (generating)
			{
				case '':
					generateVocalsFromParameterName("normal");
					generating = 'normal';
				case 'normal':
					if (generated)
					{
						normal = Bytes.alloc(masterBytes.length);
						normal.blit(0, masterBytes, 0, masterBytes.length);
						generating = 'complete';
					}
				case 'complete':
					numSamples = Std.int(masterBytes.length / bytesPerSample);
					res = Bytes.alloc(masterBytes.length);
					res.blit(0, masterBytes, 0, masterBytes.length);
					completed = true;
			}
		}
		else
		{
			switch (generating) // TODO: Put this in a for loop, I'm too lazy for it right now
			{
				case '':
					generateVocalsFromParameterName("normal");
					generating = 'normal';
				case 'normal':
					if (generated)
					{
						normal = Bytes.alloc(masterBytes.length);
						normal.blit(0, masterBytes, 0, masterBytes.length);
						if (voiceBank.mouth)
						{
							generating = 'mouth';
							generateVocalsFromParameterName("mouth");
						}
						else
						{
							if (voiceBank.breaths)
							{
								generating = 'breaths';
								generateVocalsFromParameterName("breaths");
							}
							else
							{
								if (voiceBank.power)
								{
									generating = 'power';
									generateVocalsFromParameterName("power");
								}
								else
								{
									if (voiceBank.soft)
									{
										generating = 'soft';
										generateVocalsFromParameterName("soft");
									}
									else
									{
										completed = true;
									}
								}
							}
						}
					}
				case 'mouth':
					if (generated)
					{
						mouth = Bytes.alloc(masterBytes.length);
						mouth.blit(0, masterBytes, 0, masterBytes.length);
						if (voiceBank.breaths)
						{
							generating = 'breaths';
							generateVocalsFromParameterName("breaths");
						}
						else
						{
							if (voiceBank.power)
							{
								generating = 'power';
								generateVocalsFromParameterName("power");
							}
							else
							{
								if (voiceBank.soft)
								{
									generating = 'soft';
									generateVocalsFromParameterName("soft");
								}
								else
								{
									completed = true;
								}
							}
						}
					}
				case 'breaths':
					if (generated)
					{
						breath = Bytes.alloc(masterBytes.length);
						breath.blit(0, masterBytes, 0, masterBytes.length);
						if (voiceBank.mouthBreath)
						{
							generating = 'mouthBreath';
							generateVocalsFromParameterName("mouthBreath");
						}
						else
						{
							if (voiceBank.power)
							{
								generating = 'power';
								generateVocalsFromParameterName("power");
							}
							else
							{
								if (voiceBank.soft)
								{
									generating = 'soft';
									generateVocalsFromParameterName("soft");
								}
								else
								{
									completed = true;
								}
							}
						}
					}
				case 'mouthBreath':
					if (generated)
					{
						mouthBreath = Bytes.alloc(masterBytes.length);
						mouthBreath.blit(0, masterBytes, 0, masterBytes.length);
						if (voiceBank.power)
						{
							generating = 'power';
							generateVocalsFromParameterName("power");
						}
						else
						{
							if (voiceBank.soft)
							{
								generating = 'soft';
								generateVocalsFromParameterName("soft");
							}
							else
							{
								completed = true;
							}
						}
					}
				case 'power':
					if (generated)
					{
						power = Bytes.alloc(masterBytes.length);
						power.blit(0, masterBytes, 0, masterBytes.length);
						if (voiceBank.mouthPower)
						{
							generating = 'mouthPower';
							generateVocalsFromParameterName("mouthPower");
						}
						else
						{
							if (voiceBank.soft)
							{
								generating = 'soft';
								generateVocalsFromParameterName("soft");
							}
							else
							{
								completed = true;
							}
						}
					}
				case 'mouthPower':
					if (generated)
					{
						mouthPower = Bytes.alloc(masterBytes.length);
						mouthPower.blit(0, masterBytes, 0, masterBytes.length);
						if (voiceBank.soft)
						{
							generating = 'soft';
							generateVocalsFromParameterName("soft");
						}
						else
						{
							completed = true;
						}
					}
				case 'soft':
					if (generated)
					{
						soft = Bytes.alloc(masterBytes.length);
						soft.blit(0, masterBytes, 0, masterBytes.length);
						if (voiceBank.mouthSoft)
						{
							generating = 'mouthSoft';
							generateVocalsFromParameterName("mouthSoft");
						}
						else
						{
							completed = true;
						}
					}
				case 'mouthSoft':
					if (generated)
					{
						mouthSoft = Bytes.alloc(masterBytes.length);
						mouthSoft.blit(0, masterBytes, 0, masterBytes.length);
						completed = true;
					}
			}
			trace('generating... $generating');
			if (completed)
			{
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

				var wavHeader:Bytes = AudioUtil.createWavHeader(numSamples, channels, voiceBank.sampleRate, bitsPerSample);
				var complete:Bytes = Bytes.alloc(wavHeader.length + res.length);
				complete.blit(0, wavHeader, 0, wavHeader.length);
				complete.blit(wavHeader.length, res, 0, res.length);

				#if debug File.saveBytes('vocals.wav', complete); #end
				sound = Sound.fromAudioBuffer(AudioBuffer.fromBytes(complete));
				FlxG.stage.removeEventListener(Event.ENTER_FRAME, waitForVocals);
			}
		}
	}

	public function generateVocals()
	{
		FlxG.stage.addEventListener(Event.ENTER_FRAME, waitForVocals);
	}
}
