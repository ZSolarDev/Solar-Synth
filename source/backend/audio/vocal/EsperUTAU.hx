package backend.audio.vocal;

import backend.utils.AudioUtil;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;
import sys.io.Process;

class EsperUTAU
{
	public var samples:Array<Float> = [];
	public var outputSamples:Array<Float> = [];
	public var running:Bool = true;
	public var params:String;
	public var fileName:String;

	public function new(?samples:Array<Float>, fileName:String, params:String)
	{
		if (samples != null)
			this.samples = samples;
		this.fileName = fileName;
		this.params = params;
	}

	public function run()
	{
		running = true;
		AudioUtil.writeWavFile(samples, '.\\esper\\$fileName.wav', 44100);
		Sys.command('.\\esper\\ESPER-Utau.exe "${Path.removeTrailingSlashes(Path.normalize(Sys.getCwd()))}/esper/$fileName.wav" "${Path.removeTrailingSlashes(Path.normalize(Sys.getCwd()))}/esper/${fileName}Output.wav" $params');
		if (FileSystem.exists('./esper/${fileName}Output.wav'))
		{
			// ...and the fact that in the last comment I was boasting on how clean that code was...this function chain is horrid.
			outputSamples = AudioUtil.pcm16BytesToFloatArray(ConvertFormat.convertWav(AudioUtil.floatArrayToWav(AudioUtil.readWavFile('./esper/${fileName}Output.wav'))));
			FileSystem.deleteFile('./esper/${fileName}.wav');
			FileSystem.deleteFile('./esper/${fileName}Output.wav');
			running = false;
			return;
		}
		else
		{
			FileSystem.deleteFile('./esper/${fileName}.wav');
			throw 'Resampler has failed! Please tell ZSolarDev to update this crash message to be something useful'; // 😟
		}
	}
}
