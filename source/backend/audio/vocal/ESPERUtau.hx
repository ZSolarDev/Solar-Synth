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
		if (esperPath != '')
			File.copy(esperPath, '.\\esper\\$fileName.wav.esp');
		Sys.command('.\\esper\\ESPER-Utau.exe "${Path.removeTrailingSlashes(Path.normalize(Sys.getCwd()))}/esper/$fileName.wav" "${Path.removeTrailingSlashes(Path.normalize(Sys.getCwd()))}/esper/${fileName}Output.wav" $params');
		var outputPath = './esper/${fileName}Output.wav';
		outputSamples = AudioUtil.pcm16BytesToFloatArray(ConvertFormat.convertWav(AudioUtil.floatArrayToWav(AudioUtil.readWavFile('./esper/${fileName}Output.wav'))));
		deleteEsperFile('./esper/${fileName}.wav');
		deleteEsperFile(outputPath);

		if (esperPath != '')
			deleteEsperFile('./esper/${fileName}.wav.esp');
		running = false;
		return;
	}

	static function deleteEsperFile(path:String)
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
					throw "Timeout deleting ESPER input/output/.esp.";
				// file probably still locked, wait a bit then try again
				Sys.sleep(0.05);
				waited += 0.05;
			}
		}
	}
}
