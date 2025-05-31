package backend.audio.vocal;

class ResamplerBatched
{
	public var batches:Array<{utau:Resampler, index:Int}> = [];
	public var sampleSets:Array<
		{
			samples:Array<Float>,
			esperPath:String,
			params:String,
			resamplerName:String,
			resampler:String,
			frqPath:String,
			llsmPath:String,
			llsmTmpPath:String
		}> = [];
	public var outputSampleSets:Array<Array<Float>> = [];
	public var completed:Bool = false;
	public var fileExt:String;

	public function new(sampleSets:Array<
		{
			samples:Array<Float>,
			esperPath:String,
			params:String,
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
				index: i
			});

		for (i in 0...batches.length)
			runBatch(batches[i]);
	}

	function runBatch(job:{utau:Resampler, index:Int})
	{
		job.utau.run();
		outputSampleSets[job.index] = job.utau.outputSamples;
		if (outputSampleSets.length == sampleSets.length)
			completed = true;
	}
}
