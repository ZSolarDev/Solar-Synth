package backend.audio;

import backend.song.SongValue;

class TimeStretcher
{
	static final HOP_SIZE = 512;

	public static function process(buffer:Array<Float>, sampleRate:Int, stretchFactors:Array<SongValue>):Array<Float>
	{
		stretchFactors.sort((a, b) -> Std.int(a.time - b.time));

		// Initialize single output buffer
		var output = [];
		var lastEnd = 0;

		for (i in 0...stretchFactors.length)
		{
			var current = stretchFactors[i];
			var nextTime = (i < stretchFactors.length - 1) ? stretchFactors[i + 1].time : Math.POSITIVE_INFINITY;

			var startSample = Std.int(current.time * sampleRate / 1000);
			var endSample = Std.int(Math.min(nextTime * sampleRate / 1000, buffer.length));

			var stretchFactor = stretchFactors[i].value;
			var segment = buffer.slice(startSample, endSample);

			// Process segment directly into output buffer
			processSegment(segment, stretchFactor, output, lastEnd);
			lastEnd = output.length;
		}

		return output;
	}

	public static function processInSemitones(buffer:Array<Float>, sampleRate:Int, pitchSemitones:Array<SongValue>):Array<Float>
	{
		pitchSemitones.sort((a, b) -> Std.int(a.time - b.time));

		// Initialize single output buffer
		var output = [];
		var lastEnd = 0;

		for (i in 0...pitchSemitones.length)
		{
			var current = pitchSemitones[i];
			var nextTime = (i < pitchSemitones.length - 1) ? pitchSemitones[i + 1].time : Math.POSITIVE_INFINITY;

			var startSample = Std.int(current.time * sampleRate / 1000);
			var endSample = Std.int(Math.min(nextTime * sampleRate / 1000, buffer.length));

			var stretchFactor = Math.pow(2, current.value / 12);
			var segment = buffer.slice(startSample, endSample);

			// Process segment directly into output buffer
			processSegment(segment, stretchFactor, output, lastEnd);
			lastEnd = output.length;
		}

		return output;
	}

	static function processSegment(segment:Array<Float>, stretchFactor:Float, output:Array<Float>, outputStart:Int)
	{
		var targetLength = Std.int(segment.length * stretchFactor);

		// Ensure output buffer has enough space
		while (output.length < outputStart + targetLength)
		{
			output.push(0.0);
		}

		var phaseAccum = [for (_ in 0...FFT.WIN_SIZE) 0.0];
		var prevPhase = [for (_ in 0...FFT.WIN_SIZE) 0.0];

		var readPos = 0.0;
		var writePos = outputStart;
		while (writePos < outputStart + targetLength - FFT.WIN_SIZE)
		{
			var frame = windowFrame(segment, readPos);
			var spectrum = FFT.fft(frame);

			// Reset phase accumulators for clean transitions
			if (writePos == outputStart)
			{
				for (k in 0...FFT.WIN_SIZE)
				{
					phaseAccum[k] = 0;
					prevPhase[k] = 0;
				}
			}

			processPhase(spectrum, prevPhase, phaseAccum);
			var resynFrame = FFT.ifft(spectrum);

			// Overlap-add with proper windowing
			for (i in 0...resynFrame.length)
			{
				var idx = writePos + i;
				if (idx < output.length)
				{
					output[idx] += resynFrame[i].re * FFT.HANN_WINDOW[i] * (FFT.WIN_SIZE / HOP_SIZE / 4);
				}
			}

			readPos += HOP_SIZE / stretchFactor;
			writePos += HOP_SIZE;
		}
	}

	static function windowFrame(buffer:Array<Float>, pos:Float):Array<Complex>
	{
		var frame = new Array<Complex>();
		for (i in 0...FFT.WIN_SIZE)
		{
			var idx = pos + i;
			var sample = interpolate(buffer, idx);
			frame.push(new Complex(sample * FFT.HANN_WINDOW[i], 0));
		}
		return frame;
	}

	static function interpolate(buffer:Array<Float>, pos:Float):Float
	{
		var idx = Std.int(pos);
		var frac = pos - idx;
		var a = buffer[idx];
		var b = (idx + 1 < buffer.length) ? buffer[idx + 1] : 0.0;
		return a + frac * (b - a); // Linear interpolation
	}

	static function processPhase(spectrum:Array<Complex>, prevPhase:Array<Float>, phaseAccum:Array<Float>)
	{
		final binFreq = 2 * Math.PI * HOP_SIZE / FFT.WIN_SIZE;

		for (k in 0...FFT.WIN_SIZE)
		{
			final re = spectrum[k].re;
			final im = spectrum[k].im;
			final mag = Math.sqrt(re * re + im * im);
			final phase = Math.atan2(im, re);

			// CORRECTED PHASE DIFFERENCE CALCULATION:
			var phaseDiff = phase - prevPhase[k];
			phaseDiff -= k * binFreq; // Expected phase progression
			phaseDiff = mod2pi(phaseDiff + Math.PI) - Math.PI; // Better wrapping

			// MAINTAIN ORIGINAL FREQUENCIES
			final trueFreq = k * binFreq + (phaseDiff / HOP_SIZE);
			phaseAccum[k] = trueFreq * HOP_SIZE; // RESET ACCUMULATOR

			spectrum[k] = new Complex(mag * Math.cos(phaseAccum[k]), mag * Math.sin(phaseAccum[k]));
			prevPhase[k] = phase;
		}
	}

	static function mod2pi(x:Float):Float
	{
		return x - 2 * Math.PI * Math.floor(x / (2 * Math.PI) + 0.5);
	}

	static function overlapAdd(output:Array<Float>, frame:Array<Float>, pos:Int)
	{
		final overlapFactor = FFT.WIN_SIZE / HOP_SIZE;
		for (i in 0...frame.length)
		{
			var idx = pos + i;
			if (idx < output.length)
			{
				output[idx] += frame[i] * FFT.HANN_WINDOW[i] * (FFT.WIN_SIZE / HOP_SIZE / 4);
			}
		}
	}

	static function normalize(buffer:Array<Float>):Array<Float>
	{
		var max = 0.0;
		for (s in buffer)
			if (Math.abs(s) > max)
				max = Math.abs(s);
		if (max > 0.95)
		{
			for (i in 0...buffer.length)
				buffer[i] *= (0.95 / max);
		}
		return buffer;
	}
}
