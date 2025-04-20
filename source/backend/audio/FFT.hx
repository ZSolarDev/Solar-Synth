package backend.audio;

class FFT
{
	public static final WIN_SIZE = 1024;
	public static final HOP_SIZE = 512;
	public static var TWIDDLE_FACTORS:Array<Complex> = null;
	public static var BIT_REVERSE:Array<Int> = null;
	public static var HANN_WINDOW = [
		for (i in 0...WIN_SIZE)
			0.5 - 0.5 * Math.cos(2 * Math.PI * i / (WIN_SIZE - 1))
	];

	public static function initialize()
	{
		TWIDDLE_FACTORS = precomputeTwiddles(WIN_SIZE);
		BIT_REVERSE = precomputeBitReversal(WIN_SIZE);
	}

	static function precomputeTwiddles(n:Int):Array<Complex>
	{
		var size = n;
		var result = new Array<Complex>();
		for (k in 0...size)
			result.push(new Complex(Math.cos(-2 * Math.PI * k / n), Math.sin(-2 * Math.PI * k / n)));
		return result;
	}

	static function precomputeBitReversal(n:Int):Array<Int>
	{
		var result = new Array<Int>();
		for (i in 0...n)
		{
			var x = i;
			var y = 0;
			for (bit in 0...Std.int(Math.log(n) / Math.log(2)))
			{
				y = (y << 1) | (x & 1);
				x >>= 1;
			}
			result.push(y);
		}
		return result;
	}

	public static function toComplex(realSamples:Array<Float>):Array<Complex>
		return [for (sample in realSamples) new Complex(sample, 0)];

	public static function multiplyComplex(a:Complex, b:Complex):Complex
		return new Complex(a.re * b.re - a.im * b.im, a.re * b.im + a.im * b.re);

	public static function addComplex(a:Complex, b:Complex):Complex
		return new Complex(a.re + b.re, a.im + b.im);

	public static function subtractComplex(a:Complex, b:Complex):Complex
		return new Complex(a.re - b.re, a.im - b.im);

	public static function fft(input:Array<Complex>):Array<Complex>
	{
		if (TWIDDLE_FACTORS == null)
			throw "TWIDDLE_FACTORS is not properly initialized!";
		var n = input.length;
		var result = input.copy();
		for (k in 0...n)
		{
			var revk = BIT_REVERSE[k];
			if (revk > k)
			{
				var temp = result[k];
				result[k] = result[revk];
				result[revk] = temp;
			}
		}

		var mmax = 1;
		while (n > mmax)
		{
			var istep = mmax << 1;
			for (m in 0...mmax)
			{
				var w = TWIDDLE_FACTORS[cast m * n / istep];
				var i = m;
				while (i < n)
				{
					var j = i + mmax;
					var temp = multiplyComplex(w, result[j]);
					result[j] = subtractComplex(result[i], temp);
					result[i] = addComplex(result[i], temp);
					i += istep;
				}
			}
			mmax = istep;
		}
		return result;
	}

	public static function ifftFloat(spectrum:Array<Complex>):Array<Float>
	{
		var conj = spectrum.map((c) ->
		{
			return new Complex(c.re, -c.im);
		});
		var temp = fft(conj);
		return temp.map(c -> c.re / WIN_SIZE);
	}

	public static function ifft(spectrum:Array<Complex>):Array<Complex>
	{
		var conj = spectrum.map((c) ->
		{
			return new Complex(c.re, -c.im);
		});

		var temp = fft(conj);

		return temp.map(c -> new Complex(c.re / WIN_SIZE, c.im / WIN_SIZE));
	}

	/**
	 * Computes the Short-Time Fourier Transform (STFT) of the input signal.
	 *
	 * @param input The input signal as an array of floats.
	 * @param window The window function to apply to each frame.
	 * @param hopSize The number of samples to advance between frames.
	 * @return A 2D array representing the STFT, with time frames along one axis and frequency bins along the other.
	 */
	public static function stft(input:Array<Float>, window:Array<Float>, hopSize:Int):Array<Array<Complex>>
	{
		var numFrames = Math.ceil(input.length / hopSize);
		var stftResult = new Array<Array<Complex>>();

		for (frameIdx in 0...numFrames)
		{
			var frameStart = frameIdx * hopSize;
			var frameEnd = Math.min(frameStart + window.length, input.length);
			var frameLength = frameEnd - frameStart;

			// Apply window function
			var windowedFrame = new Array<Float>();
			for (i in 0...cast frameLength)
			{
				windowedFrame.push(input[frameStart + i] * window[i]);
			}

			// Zero-padding if necessary
			while (windowedFrame.length < window.length)
			{
				windowedFrame.push(0.0);
			}

			// Compute FFT of the windowed frame
			var complexFrame = toComplex(windowedFrame);
			var spectrum = fft(complexFrame);
			stftResult.push(spectrum);
		}

		return stftResult;
	}

	/**
	 * Computes the Inverse Short-Time Fourier Transform (ISTFT) from the given STFT.
	 *
	 * @param stft The STFT as a 2D array of Complex numbers (frequency bins x time frames).
	 * @param window The window function applied during STFT (e.g., Hanning window).
	 * @param hopSize The number of samples between the start of consecutive frames.
	 * @return The reconstructed time-domain signal as an array of Floats.
	 */
	public static function istft(stft:Array<Array<Complex>>, window:Array<Float>, hopSize:Int):Array<Float>
	{
		var numFrames = stft.length;
		var signalLength = (numFrames - 1) * hopSize + window.length;
		var reconstructedSignal = [];

		// Initialize the reconstructed signal with zeros
		for (i in 0...signalLength)
		{
			reconstructedSignal[i] = 0.0;
		}

		// Overlap-add method to reconstruct the signal
		for (frameIdx in 0...numFrames)
		{
			var frameStart = frameIdx * hopSize;
			var frameEnd = Math.min(frameStart + window.length, signalLength);
			var frameLength = frameEnd - frameStart;

			// Compute the inverse FFT of the current frame
			var spectrum = stft[frameIdx];
			var timeDomainFrame = ifft(spectrum);

			// Apply the window function and overlap-add
			for (i in 0...cast frameLength)
			{
				reconstructedSignal[frameStart + i] += timeDomainFrame[i].re * window[i];
			}
		}

		return reconstructedSignal;
	}
}
