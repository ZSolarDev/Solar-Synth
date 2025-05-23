package backend.audio.vocal;

import sys.io.Process;
import sys.thread.Mutex;
import sys.thread.Thread;

class ESPERUtauThreaded
{
	public var mutex = new Mutex();
	public var numThreads:Int;
	public var threadBatches:Array<Array<{utau:ESPERUtau, index:Int}>> = [];
	public var sampleSets:Array<{samples:Array<Float>, params:String}> = [];
	public var outputSampleSets:Array<Array<Float>> = [];
	public var completed:Bool = false;

	public function new(sampleSets:Array<{samples:Array<Float>, params:String}>)
	{
		this.sampleSets = sampleSets;
		numThreads = getCPUThreads() - 2;

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
			threadBatches[threadIndex].push({utau: new ESPERUtau(sampleSets[i].samples, fileName, sampleSets[i].params), index: i});
		}

		for (i in 0...numThreads)
			Thread.create(() -> runBatch(threadBatches[i]));
	}

	function runBatch(batch:Array<{utau:ESPERUtau, index:Int}>)
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

	function getCPUThreads():Int
	{
		try
		{
			#if sys
			var proc = new Process("cmd /c echo %NUMBER_OF_PROCESSORS%");
			var output = proc.stdout.readAll().toString().trim();
			proc.close();
			return Std.parseInt(output);
			#else
			return 4; // fallback default
			#end
		}
		catch (_)
			return 4; // fallback on error
	}
}
