package fft;

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

	public static function fftFloat(input:Array<Float>):Array<Complex>
		return fft(input.map(v -> new Complex(v, 0)));

	public static function fft(input:Array<Complex>):Array<Complex>
	{
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
					if (result[j] == null)
						throw 'waa. $i';
					if (w == null)
						throw 'woo. $m | $n | $istep';
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

	public static function updateFrameMagnitudes(frame:Array<Complex>, magnitudes:Array<Float>):Void
	{
		for (i in 0...frame.length)
		{
			var old = frame[i];
			var phase = Math.atan2(old.im, old.re);
			var mag = magnitudes[i];
			frame[i] = new Complex(Math.cos(phase) * mag, Math.sin(phase) * mag);
		}
	}

	public static function getMagnitudes(frame:Array<Complex>):Array<Float>
		return frame.map(c -> Math.sqrt(c.re * c.re + c.im * c.im));

	public static function fftFull(samples:Array<Float>):Array<Complex>
	{
		var frames = new Array<Array<Complex>>();

		var pos = 0;
		while (pos + WIN_SIZE <= samples.length)
		{
			var window = samples.slice(pos, pos + WIN_SIZE);

			for (i in 0...window.length)
				window[i] *= HANN_WINDOW[i];

			frames.push(fftFloat(window));
			pos += HOP_SIZE;
		}
		var fullSpectrum = new Array<Complex>();
		for (frame in frames)
			for (complex in frame)
				fullSpectrum.push(complex);
		return fullSpectrum;
	}

	public static function deconstructComplex(input:Array<Complex>):Array<Float>
	{
		var res = new Array<Float>();
		for (i in 0...input.length)
		{
			res.push(input[i].re);
			res.push(input[i].im);
		}
		return res;
	}

	public static function pairFloatsToComplex(input:Array<Float>):Array<Complex>
	{
		var res = new Array<Complex>();
		var mode = 0;
		var curPair:{re:Float, im:Float} = null;
		for (i in 0...input.length)
		{
			if (mode == 0)
			{
				mode = 1;
				curPair = {re: input[i], im: 0};
			}
			else
			{
				mode = 0;
				curPair.im = input[i];
				res.push(new Complex(curPair.re, curPair.im));
				curPair = null;
			}
		}
		return res;
	}

	public static function ifftFloat(spectrum:Array<Complex>):Array<Float>
		return fft(spectrum.map((c) ->
		{
			return new Complex(c.re, -c.im);
		})).map(c -> c.re / WIN_SIZE);

	public static function ifft(spectrum:Array<Complex>):Array<Complex>
		return fft(spectrum.map((c) ->
		{
			return new Complex(c.re, -c.im);
		})).map(c -> new Complex(c.re / WIN_SIZE, c.im / WIN_SIZE));
}
