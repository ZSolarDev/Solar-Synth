package backend.audio.vocal;

import backend.utils.AudioUtil;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;

class Resampler
{
	public var samples:Array<Float> = [];
	public var outputSamples:Array<Float> = [];
	public var running:Bool = true;
	public var params:String;
	public var fileName:String;
	public var frqPath:String;
	public var esperPath:String;
	public var llsmPath:String;
	public var llsmTmpPath:String;
	public var resamplerName:String;
	public var resampler:String;

	public function new(?samples:Array<Float>, resamplerName:String, resampler:String, frqPath:String, esperPath:String, llsmPath:String, llsmTmpPath:String,
			fileName:String, params:String)
	{
		if (samples != null)
			this.samples = samples;
		this.fileName = fileName;
		this.params = params;
		this.frqPath = frqPath;
		this.esperPath = esperPath;
		this.llsmPath = llsmPath;
		this.llsmTmpPath = llsmTmpPath;
		this.resamplerName = resamplerName;
		this.resampler = resampler;
	}

	public function run()
	{
		running = true;
		AudioUtil.writeWavFile(samples, '.\\resamplers\\$resamplerName\\$fileName.wav', 44100);
		if (frqPath != '')
			File.copy(frqPath, '.\\resamplers\\$resamplerName\\${fileName}_wav.frq');
		if (esperPath != '')
			File.copy(esperPath, '.\\resamplers\\$resamplerName\\$fileName.wav.esp');
		if (llsmPath != '')
			File.copy(llsmPath, '.\\resamplers\\$resamplerName\\$fileName.wav.llsm');
		if (llsmTmpPath != '')
			File.copy(llsmTmpPath, '.\\resamplers\\$resamplerName\\$fileName.wav.llsm.tmp');

		Sys.command('.\\resamplers\\$resamplerName\\$resampler "${Path.removeTrailingSlashes(Path.normalize(Sys.getCwd()))}/resamplers/$resamplerName/$fileName.wav" "${Path.removeTrailingSlashes(Path.normalize(Sys.getCwd()))}/resamplers/$resamplerName/${fileName}Output.wav" $params');
		var outputPath = './resamplers/$resamplerName/${fileName}Output.wav';
		outputSamples = AudioUtil.pcm16BytesToFloatArray(ConvertFormat.convertWav(AudioUtil.floatArrayToWav(AudioUtil.readWavFile('./resamplers/$resamplerName/${fileName}Output.wav'))));
		deleteResamplerFile('./resamplers/$resamplerName/${fileName}.wav');
		deleteResamplerFile(outputPath);

		if (frqPath != '')
			deleteResamplerFile('./resamplers/$resamplerName/${fileName}_wav.frq');
		if (esperPath != '')
			deleteResamplerFile('./resamplers/$resamplerName/${fileName}.wav.esp');
		if (llsmPath != '')
			deleteResamplerFile('./resamplers/$resamplerName/${fileName}.wav.llsm');
		if (llsmTmpPath != '')
			deleteResamplerFile('./resamplers/$resamplerName/${fileName}.wav.llsm.tmp');
		running = false;
		return;
	}

	static function deleteResamplerFile(path:String)
	{
		var waited = 0.0;
		while (true) // why do I need all this shit to delete a fileee 😭
		{
			try
			{
				FileSystem.deleteFile(path);
				return;
			}
			catch (e:Dynamic)
			{
				if (waited >= 5)
					throw "Timeout deleting Resampler input/output/esp/llsm/llsm.tmp/frq file.";
				// file probably still locked, wait a bit then try again
				Sys.sleep(0.05);
				waited += 0.05;
			}
		}
	}
}
