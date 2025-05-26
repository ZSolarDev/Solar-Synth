package backend.audio.vocal;

import backend.song.Note;
import backend.song.Voicebank;
import backend.utils.ThreadUtil;
import sys.io.Process;
import sys.thread.Mutex;
import sys.thread.Thread;

class VocalSynthesizerThreaded
{
	public var mutex = new Mutex();
	public var numThreads:Int;
	public var threadBatches:Array<Array<String>> = [];
	public var batches:Array<String> = [
		"normal",
		"mouth",
		"breaths",
		"mouthBreath",
		"power",
		"mouthPower",
		"soft",
		"mouthSoft"
	];
	public var output:Map<String, Bytes> = new Map();
	public var completed:Bool = false;
	public var notes:Array<Note>;
	public var voiceBank:Voicebank;
	public var esperMode:Bool;

	public function new(notes:Array<Note>, voiceBank:Voicebank, ?esperMode:Bool = false)
	{
		this.notes = notes;
		this.voiceBank = voiceBank;
		this.esperMode = esperMode;
		// leave *around* 1/2 of threads free for other tasks
		numThreads = ThreadUtil.freeThreads;

		// Remove what we dont have(this code is so ugly oh my fucking god)
		if (esperMode)
			batches = ['normal'];
		else
		{
			if (!voiceBank.mouth)
				batches.remove("mouth");
			if (!voiceBank.breaths)
				batches.remove("breaths");
			if (!voiceBank.mouthBreath)
				batches.remove("mouthBreath");
			if (!voiceBank.power)
				batches.remove("power");
			if (!voiceBank.mouthPower)
				batches.remove("mouthPower");
			if (!voiceBank.soft)
				batches.remove("soft");
			if (!voiceBank.mouthSoft)
				batches.remove("mouthSoft");
		}

		for (_ in 0...numThreads)
			threadBatches.push([]);
	}

	public function runBatches()
	{
		// distribute sample sets across threads using wraparound
		for (i in 0...batches.length)
			threadBatches[i % numThreads].push(batches[i]);
		for (i in 0...numThreads)
			ThreadUtil.createThread(() -> runBatch(threadBatches[i]));
	}

	function runBatch(batch:Array<String>)
	{
		for (job in batch)
		{
			VocalSynthesizer.synthesizeVocalsFromParameterName(job, notes, voiceBank, esperMode);
			while (!VocalSynthesizer.curParamComplete)
				Sys.sleep(0.001);
			var bytes = Bytes.alloc(VocalSynthesizer.curParamBytes.length);
			bytes.blit(0, VocalSynthesizer.curParamBytes, 0, VocalSynthesizer.curParamBytes.length);
			mutex.acquire();
			output.set(job, bytes);
			if (Lambda.count(output) == batches.length)
				completed = true;
			mutex.release();
		}
	}
}
