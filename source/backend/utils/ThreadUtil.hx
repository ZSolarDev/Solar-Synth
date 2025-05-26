package backend.utils;

import sys.io.Process;
import sys.thread.Thread;

class ThreadUtil
{
	public static var totalThreads(get, null):Int;
	public static var freeThreads(get, null):Int;
	private static var threadsUsed:Int = 1; // One is always used as the main thread

	// TODO: Make this use global config. after that, make it dynamic instead of manually set. Not everyone is gonna have 12 threads
	static function get_totalThreads():Int
	{
		var totalThreads = 12;

		/* how does this not work?? I tested it in command line and it worked fine..
			try
			{
				
				var proc = new Process("cmd /c echo %NUMBER_OF_PROCESSORS%");
				var output = proc.stdout.readAll().toString().trim();
				proc.close();
				totalThreads = Std.parseInt(output);
			}
			catch (e)
			{
				trace(ErrorUtil.formatError(e, 'getting total thread count'));
				totalThreads = 4; // fallback. you can't tell me someone is running this on a system with less than 4 threads available
			}
		 */
		return totalThreads;
	}

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
