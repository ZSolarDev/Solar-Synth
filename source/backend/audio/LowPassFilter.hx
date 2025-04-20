package backend.audio;

class LowPassFilter
{
	public static function apply(input:Array<Complex>, cutoffFreq:Float, sampleRate:Float):Array<Complex>
	{
		// Calculate the time constant for the filter
		var rc:Float = 1.0 / (2 * Math.PI * cutoffFreq);
		var dt:Float = 1.0 / sampleRate;
		var alpha:Float = dt / (rc + dt);

		// Initialize the output array
		var output:Array<Complex> = new Array<Complex>();

		// Initialize previous output values for both real and imaginary parts
		var previousReal:Float = 0.0;
		var previousImag:Float = 0.0;

		// Apply low-pass filter on each complex sample (real and imaginary parts)
		for (i in 0...input.length)
		{
			// Apply low-pass filter to the real part
			var filteredReal:Float = alpha * input[i].re + (1 - alpha) * previousReal;

			// Apply low-pass filter to the imaginary part
			var filteredImag:Float = alpha * input[i].im + (1 - alpha) * previousImag;

			// Push the filtered complex value to the output array
			output.push(new Complex(filteredReal, filteredImag));

			// Update previous real and imaginary parts for next iteration
			previousReal = filteredReal;
			previousImag = filteredImag;
		}

		return output;
	}

	public static function applyDefaultFilter(input:Array<Complex>, sampleRate:Float = 44100.0):Array<Complex>
	{
		var cutoffFreq:Float = 8000.0;
		return apply(input, cutoffFreq, sampleRate);
	}
}
