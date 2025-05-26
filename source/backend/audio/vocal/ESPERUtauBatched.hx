package backend.audio.vocal;

import backend.song.Note;
import backend.song.Voicebank;

class ESPERUtauBatched
{
	public var batches:Array<{utau:ESPERUtau, index:Int}> = [];
	public var sampleSets:Array<{samples:Array<Float>, params:String}> = [];
	public var outputSampleSets:Array<Array<Float>> = [];
	public var completed:Bool = false;
	public var fileExt:String;
	// For data transfer in VocalSynthesizer
	public var notes:Array<Note> = [];
	public var voiceBank:Voicebank;
	public var esperMode:Bool;

	public function new(sampleSets:Array<{samples:Array<Float>, params:String}>, fileExt:String)
	{
		this.sampleSets = sampleSets;
		this.fileExt = fileExt;
	}

	public function runBatches()
	{
		for (i in 0...sampleSets.length)
			batches.push({utau: new ESPERUtau(sampleSets[i].samples, '$i-$fileExt', sampleSets[i].params), index: i});

		for (i in 0...batches.length)
			runBatch(batches[i]);
	}

	function runBatch(job:{utau:ESPERUtau, index:Int})
	{
		job.utau.run();
		outputSampleSets[job.index] = job.utau.outputSamples;
		if (outputSampleSets.length == sampleSets.length)
			completed = true;
	}
}
