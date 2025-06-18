package backend.utils;

#if hl
import hlwnative.HLApplicationStatus;
#end
import sys.thread.Thread;

class ThreadUtil
{
	public static var totalThreads(get, null):Int;
	public static var freeThreads(get, null):Int;
	private static var threadsUsed:Int = 1; // One is always used as the main thread

	#if hl
	static function get_totalThreads():Int
		return cast HLApplicationStatus.getTotalThreads();
	#else
	static function get_totalThreads():Int
		return 4;
	#end

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
