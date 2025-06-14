package backend.audio.vocal;

import backend.utils.ThreadUtil;
import sys.thread.Mutex;
import sys.thread.Thread;

class ResamplerThreaded
{
	// This is the first time i've used a mutex
	public var mutex = new Mutex();
	public var numThreads:Int;
	public var threadBatches:Array<Array<{utau:Resampler, index:Int}>> = [];
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
		}>)
	{
		this.sampleSets = sampleSets;
		// leave *around* 1/2 of threads free for other tasks
		numThreads = Math.round(ThreadUtil.freeThreads / 2);

		for (_ in 0...numThreads)
			threadBatches.push([]);
	}

	public function runBatches()
	{
		// distribute sample sets across threads using wraparound
		for (i in 0...sampleSets.length)
		{
			var threadIndex = i % numThreads;
			var fileName = '$i';
			threadBatches[threadIndex].push({
				utau: new Resampler(sampleSets[i].samples, sampleSets[i].resamplerName, sampleSets[i].resampler, sampleSets[i].frqPath,
					sampleSets[i].esperPath, sampleSets[i].llsmPath, sampleSets[i].llsmTmpPath, fileName, sampleSets[i].params),
				index: i
			});
		}

		for (i in 0...numThreads)
			ThreadUtil.createThread(() -> runBatch(threadBatches[i]));
	}

	function runBatch(batch:Array<{utau:Resampler, index:Int}>)
	{
		for (job in batch)
		{
			job.utau.run();
			mutex.acquire();
			outputSampleSets[job.index] = job.utau.outputSamples;
			if (outputSampleSets.length == sampleSets.length)
				completed = true;
			mutex.release();
		}
	}
}
