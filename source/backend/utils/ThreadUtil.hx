package backend.utils;

#if hl
import hlwnative.HLApplicationStatus;
import sys.thread.Thread;
#end

class ThreadUtil
{
	public static var totalThreads(get, null):Int;
	public static var freeThreads(get, null):Int;
	private static var threadsUsed:Int = 1; // One is always used as the main thread

	static function get_totalThreads():Int
		return #if hl cast HLApplicationStatus.getTotalThreads(); #else 1 #end

	static function get_freeThreads():Int
		return totalThreads - threadsUsed;

	public static function createThread(job:() -> Void)
	{
		#if hl
		if (freeThreads > 0)
		{
			threadsUsed++;
			Thread.create(() ->
			{
				job();
				threadsUsed--;
			});
		}
		#else
		job();
		#end
	}
}
