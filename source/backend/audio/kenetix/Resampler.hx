package backend.audio.kenetix;

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

		trace('.\\resamplers\\$resamplerName\\$fileName.wav');
		trace('${Path.removeTrailingSlashes(Path.normalize(Sys.getCwd()))}/resamplers/$resamplerName/$fileName.wav');
		Sys.command('.\\resamplers\\$resamplerName\\$resampler "${Path.removeTrailingSlashes(Path.normalize(Sys.getCwd()))}/resamplers/$resamplerName/$fileName.wav" "${Path.removeTrailingSlashes(Path.normalize(Sys.getCwd()))}/resamplers/$resamplerName/${fileName}Output.wav" $params');
		var outputPath = './resamplers/$resamplerName/${fileName}Output.wav';
		runFileTask(() ->
		{
			outputSamples = AudioUtil.pcm16BytesToFloatArray(ConvertFormat.convertWav(AudioUtil.floatArrayToWav(AudioUtil.readWavFile('./resamplers/$resamplerName/${fileName}Output.wav'))));
		});
		runFileTask(() ->
		{
			FileSystem.deleteFile('./resamplers/$resamplerName/${fileName}.wav');
		});
		runFileTask(() ->
		{
			FileSystem.deleteFile(outputPath);
		});

		// TODO: Clean this up
		if (FileSystem.exists('./resamplers/$resamplerName/${fileName}_wav.frq'))
			runFileTask(() ->
			{
				FileSystem.deleteFile('./resamplers/$resamplerName/${fileName}_wav.frq');
			});
		if (FileSystem.exists('./resamplers/$resamplerName/${fileName}.wav.esp'))
			runFileTask(() ->
			{
				FileSystem.deleteFile('./resamplers/$resamplerName/${fileName}.wav.esp');
			});
		if (FileSystem.exists('./resamplers/$resamplerName/${fileName}.wav.llsm'))
			runFileTask(() ->
			{
				FileSystem.deleteFile('./resamplers/$resamplerName/${fileName}.wav.llsm');
			});
		if (FileSystem.exists('./resamplers/$resamplerName/${fileName}.wav.llsm.tmp'))
			runFileTask(() ->
			{
				FileSystem.deleteFile('./resamplers/$resamplerName/${fileName}.wav.llsm.tmp');
			});
		running = false;
		return;
	}

	static function runFileTask(task:() -> Void)
	{
		var waited = 0.0;
		while (true) // why do I need all this shit to delete/read a fileee 😭
		{
			try
			{
				task();
				return;
			}
			catch (e)
			{
				if (waited >= 5)
					throw 'Timeout running file task: ${e.message}\n${e.stack.toString()}';
				// file probably still locked, wait a bit then try again
				Sys.sleep(0.05);
				waited += 0.05;
			}
		}
	}
}
