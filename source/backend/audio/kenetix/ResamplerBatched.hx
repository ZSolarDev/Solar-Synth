package backend.audio.kenetix;

import backend.data.Note;

class ResamplerBatched
{
	public var batches:Array<{utau:Resampler, index:Int, note:Note}> = [];
	public var sampleSets:Array<
		{
			samples:Array<Float>,
			esperPath:String,
			params:String,
			note:Note,
			resamplerName:String,
			resampler:String,
			frqPath:String,
			llsmPath:String,
			llsmTmpPath:String
		}> = [];
	public var outputSampleSets:Array<{samples:Array<Float>, note:Note}> = [];
	public var completed:Bool = false;
	public var fileExt:String;

	public function new(sampleSets:Array<
		{
			samples:Array<Float>,
			esperPath:String,
			params:String,
			note:Note,
			resamplerName:String,
			resampler:String,
			frqPath:String,
			llsmPath:String,
			llsmTmpPath:String
		}>, fileExt:String)
	{
		this.sampleSets = sampleSets;
		this.fileExt = fileExt;
	}

	public function runBatches()
	{
		for (i in 0...sampleSets.length)
			batches.push({
				utau: new Resampler(sampleSets[i].samples, sampleSets[i].resamplerName, sampleSets[i].resampler, sampleSets[i].frqPath,
					sampleSets[i].esperPath, sampleSets[i].llsmPath, sampleSets[i].llsmTmpPath, '$i-$fileExt', sampleSets[i].params),
				index: i,
				note: sampleSets[i].note
			});

		for (i in 0...batches.length)
			runBatch(batches[i]);
	}

	function runBatch(job:{utau:Resampler, index:Int, note:Note})
	{
		job.utau.run();
		outputSampleSets[job.index] = {
			samples: job.utau.outputSamples,
			note: job.note
		};
		if (outputSampleSets.length == sampleSets.length)
			completed = true;
	}
}
