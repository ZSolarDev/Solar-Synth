package backend.audio.vocal;

import sys.io.Process;
import sys.thread.Thread;

class EsperUTAUThreading
{
	public var numThreads:Int;
	public var threadBatches:Array<Array<EsperUTAU>> = [];
	public var sampleSets:Array<{samples:Array<Float>, params:String}> = [];
	public var outputSampleSets:Array<Array<Float>>;
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
			threadBatches[threadIndex].push(new EsperUTAU(sampleSets[i].samples, fileName, sampleSets[i].params));
		}

		for (i in 0...numThreads)
			Thread.create(() -> runBatch(threadBatches[i]));
	}

	function runBatch(batch:Array<EsperUTAU>)
	{
		for (job in batch)
		{
			job.run();
			outputSampleSets.push(job.outputSamples);
			if (outputSampleSets.length == sampleSets.length)
				completed = true;
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
