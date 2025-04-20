package backend.audio;

import Math;
import Std;
import backend.song.SongValue;

class FormantCorrector
{
	/*
		public static var frameSize:Int = FFT.WIN_SIZE;
		public static var hopSize:Int = FFT.HOP_SIZE;

		public static function process(input:Array<Float>, sampleRate:Int, values:Array<SongValue>):Array<Float>
		{
			// Prepare an output buffer filled with zeros.
			var output:Array<Float> = new Array<Float>();
			for (i in 0...input.length)
				output.push(0);

			var frameStart:Int = 0;
			while (frameStart < input.length)
			{
				// Extract one frame (pad with zeros if needed).
				var frame:Array<Float> = new Array<Float>();
				for (i in 0...frameSize)
				{
					var idx = frameStart + i;
					if (idx < input.length)
						frame.push(input[idx]);
					else
						frame.push(0.0);
				}

				// Apply a window function to reduce artifacts (Hamming window)
				var windowedFrame:Array<Float> = new Array<Float>();
				for (i in 0...frame.length)
				{
					var windowFactor:Float = 0.54 - 0.46 * Math.cos(2 * Math.PI * i / (frameSize - 1));
					windowedFrame.push(frame[i] * windowFactor);
				}

				// Compute the time in ms at the frame's center.
				var timeMs:Float = ((frameStart + frameSize / 2) / sampleRate) * 1000;
				// Get the formant shift value from the values curve.
				var formantShiftSemitones:Float = getAutomationValue(values, timeMs);
				// Calculate the formant shift ratio
				var formantShiftRatio:Float = Math.pow(2, formantShiftSemitones / 12);

				// Convert to frequency domain
				var complexFrame:Array<Complex> = new Array<Complex>();
				for (i in 0...frameSize)
					complexFrame.push(new Complex(windowedFrame[i], 0));

				var spectrum:Array<Complex> = FFT.fft(complexFrame);

				// Extract the spectral envelope using cepstral analysis
				var logMagnitude:Array<Float> = getLogMagnitudeSpectrum(spectrum);
				var spectralEnvelope:Array<Float> = extractSpectralEnvelope(logMagnitude, sampleRate);

				// Shift formants by modifying the spectral envelope
				var modifiedEnvelope:Array<Float> = shiftFormants(spectralEnvelope, formantShiftRatio);

				// Apply the modified envelope to the original spectrum (preserving phase)
				var correctedSpectrum:Array<Complex> = applyEnvelopeToSpectrum(spectrum, modifiedEnvelope);

				// Convert back to time domain
				var processedComplex:Array<Complex> = FFT.ifft(correctedSpectrum);

				// Apply window again for proper overlap-add
				var processedFrame:Array<Float> = new Array<Float>();
				for (i in 0...frameSize)
				{
					var windowFactor:Float = 0.54 - 0.46 * Math.cos(2 * Math.PI * i / (frameSize - 1));
					processedFrame.push(processedComplex[i].re * windowFactor);
				}

				// Use overlap-add to reconstruct the signal
				for (i in 0...frameSize)
				{
					var idx = frameStart + i;
					if (idx < output.length)
						output[idx] += processedFrame[i];
				}

				frameStart += hopSize;
			}

			// Normalize the output to account for the overlap-add gain
			var normalizationFactor:Float = frameSize / (2.0 * hopSize); // For Hamming window
			for (i in 0...output.length)
			{
				output[i] /= normalizationFactor;
			}

			return output;
		}
		static function getAutomationValue(values:Array<SongValue>, timeMs:Float):Float
		{
			if (values.length == 0)
				return 0;
			if (timeMs <= values[0].time)
				return values[0].value;
			if (timeMs >= values[values.length - 1].time)
				return values[values.length - 1].value;

			for (i in 0...values.length - 1)
			{
				var cur:SongValue = values[i];
				var next:SongValue = values[i + 1];
				if (timeMs >= cur.time && timeMs <= next.time)
				{
					var t:Float = (timeMs - cur.time) / (next.time - cur.time);
					return cur.value * (1 - t) + next.value * t;
				}
			}
			return 0; // fallback (should not reach here)
		}

		static function getLogMagnitudeSpectrum(spectrum:Array<Complex>):Array<Float>
		{
			return spectrum.map(c -> Math.log(Math.sqrt(c.re * c.re + c.im * c.im) + 1e-6));
		}

		static function extractSpectralEnvelope(logMagnitude:Array<Float>, sampleRate:Int):Array<Float>
		{
			// Convert log-magnitude spectrum to complex array for IFFT
			var complexLogMagnitude:Array<Complex> = logMagnitude.map(mag -> new Complex(mag, 0));

			// Perform IFFT to get the cepstrum
			var cepstrum:Array<Complex> = FFT.ifft(complexLogMagnitude);

			// Liftering: keep only the first few cepstral coefficients
			// This determines the smoothness of the envelope
			var cutoff:Int = Std.int(Math.min(30, cepstrum.length / 20)); // Typical cutoff for formant preservation

			for (i in 0...cepstrum.length)
			{
				// Apply liftering window (rectangular window for simplicity)
				if (i > cutoff && i < cepstrum.length - cutoff)
					cepstrum[i] = new Complex(0, 0);
			}

			// Convert back to spectrum domain to get the envelope
			var smoothedSpectrum:Array<Complex> = FFT.fft(cepstrum);

			// Convert to magnitude
			return smoothedSpectrum.map(c -> Math.exp(c.re));
		}

		static function shiftFormants(envelope:Array<Float>, shiftRatio:Float):Array<Float>
		{
			var modifiedEnvelope:Array<Float> = new Array<Float>();
			var halfLength:Int = Std.int(envelope.length / 2);

			for (i in 0...envelope.length)
			{
				// For the first half of the spectrum (positive frequencies)
				if (i < halfLength)
				{
					var newIndex:Float = i * shiftRatio;
					var baseIndex:Int = Std.int(newIndex);
					var fraction:Float = newIndex - baseIndex;

					// Linear interpolation
					if (baseIndex + 1 < halfLength)
					{
						modifiedEnvelope.push(envelope[baseIndex] * (1 - fraction) + envelope[baseIndex + 1] * fraction);
					}
					else
					{
						modifiedEnvelope.push(envelope[baseIndex]);
					}
				}
				// Mirror for the second half (negative frequencies) to maintain symmetry
				else
				{
					modifiedEnvelope.push(modifiedEnvelope[envelope.length - i - 1]);
				}
			}

			return modifiedEnvelope;
		}

		static function applyEnvelopeToSpectrum(spectrum:Array<Complex>, envelope:Array<Float>):Array<Complex>
		{
			var correctedSpectrum:Array<Complex> = new Array<Complex>();

			for (i in 0...spectrum.length)
			{
				var magnitude:Float = Math.sqrt(spectrum[i].re * spectrum[i].re + spectrum[i].im * spectrum[i].im);
				var phase:Float = Math.atan2(spectrum[i].im, spectrum[i].re);

				// Avoid division by zero
				var scaleFactor:Float = (magnitude < 1e-6) ? 0 : envelope[i] / magnitude;

				// Apply envelope magnitude while preserving original phase
				var realPart:Float = scaleFactor * spectrum[i].re;
				var imagPart:Float = scaleFactor * spectrum[i].im;

				correctedSpectrum.push(new Complex(realPart, imagPart));
			}

			return correctedSpectrum;
		}
	 */
}
