package backend.utils;

import hlwnative.HLApplicationStatus;
import sys.io.Process;
import sys.thread.Thread;

class ThreadUtil
{
	public static var totalThreads(get, null):Int;
	public static var freeThreads(get, null):Int;
	private static var threadsUsed:Int = 1; // One is always used as the main thread

	static function get_totalThreads():Int
		return cast HLApplicationStatus.getTotalThreads();

	static function get_freeThreads():Int
		return totalThreads - threadsUsed;

	public static function createThread(job:() -> Void)
	{
		if (freeThreads > 0)
		{
			threadsUsed++;
			Thread.create(() ->
			{
				job();
				threadsUsed--;
			});
		}
	}
}
