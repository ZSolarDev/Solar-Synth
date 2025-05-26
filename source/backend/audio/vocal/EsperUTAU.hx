package backend.audio.vocal;

import backend.utils.AudioUtil;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;

class ESPERUtau
{
	public var samples:Array<Float> = [];
	public var outputSamples:Array<Float> = [];
	public var running:Bool = true;
	public var params:String;
	public var fileName:String;
	public var esperPath:String;

	public function new(?samples:Array<Float>, esperPath:String, fileName:String, params:String)
	{
		if (samples != null)
			this.samples = samples;
		this.fileName = fileName;
		this.params = params;
		this.esperPath = esperPath;
	}

	public function run()
	{
		running = true;
		AudioUtil.writeWavFile(samples, '.\\esper\\$fileName.wav', 44100);
		trace(esperPath);
		if (esperPath != '')
			File.copy(esperPath, '.\\esper\\$fileName.wav.esp');
		Sys.command('.\\esper\\ESPER-Utau.exe "${Path.removeTrailingSlashes(Path.normalize(Sys.getCwd()))}/esper/$fileName.wav" "${Path.removeTrailingSlashes(Path.normalize(Sys.getCwd()))}/esper/${fileName}Output.wav" $params');
		if (FileSystem.exists('./esper/${fileName}Output.wav'))
		{
			outputSamples = AudioUtil.pcm16BytesToFloatArray(ConvertFormat.convertWav(AudioUtil.floatArrayToWav(AudioUtil.readWavFile('./esper/${fileName}Output.wav'))));
			FileSystem.deleteFile('./esper/${fileName}.wav');
			FileSystem.deleteFile('./esper/${fileName}Output.wav');
			if (esperPath != '')
				FileSystem.deleteFile('./esper/${fileName}.wav.esp');
			running = false;
			return;
		}
		else
		{
			FileSystem.deleteFile('./esper/${fileName}.wav');
			if (esperPath != '')
				FileSystem.deleteFile('./esper/${fileName}.wav.esp');
			throw 'Resampler has failed! Please tell ZSolarDev to update this crash message to be something useful'; // 😟
		}
	}
}
