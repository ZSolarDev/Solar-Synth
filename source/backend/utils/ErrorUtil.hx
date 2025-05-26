package backend.utils;

import haxe.Exception;

class ErrorUtil
{
	public static function formatError(e:Exception, ?attemptedTask:String):String
		return (attemptedTask != null ? 'Error while ' + attemptedTask + ': ' : 'Error: ') + e.message + '\n' + e.stack.toString();
}
