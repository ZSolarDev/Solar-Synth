package fft;

import libesper.LibESPER;

class FFTHelper
{
	public static function generateFrames(spectrum:Array<Complex>):Array<Array<Complex>>
	{
		var frames = [];

		var frameSize = LibESPER.engineConfig.frameSize;
		var nHarmonics = LibESPER.engineConfig.nHarmonics;

		var frameCount = Std.int(spectrum.length / nHarmonics);

		for (i in 0...frameCount)
		{
			var frame = new Array<Complex>();

			for (j in 0...nHarmonics)
			{
				var index = i * nHarmonics + j;
				if (index >= spectrum.length)
					break;

				frame.push(new Complex(spectrum[index].re, spectrum[index].im));
			}

			// Pad to frameSize if needed
			while (frame.length < frameSize)
				frame.push(new Complex(0, 0));

			frames.push(frame);
		}

		return frames;
	}

	static function extractFrameFromFFT(fft:Array<Float>):Array<Float>
	{
		var frame = new Array<Float>();

		// Only take the magnitude of first 64 bins (meaning 128 floats because real+imag)
		for (i in 0...LibESPER.engineConfig.nHarmonics)
		{
			var re = fft[i * 2]; // Real part
			var im = fft[i * 2 + 1]; // Imag part
			var magnitude = Math.sqrt(re * re + im * im);
			frame.push(magnitude);
		}

		// Fill the rest with zeros to reach 355
		while (frame.length < LibESPER.engineConfig.frameSize)
			frame.push(0);

		return frame;
	}
}
