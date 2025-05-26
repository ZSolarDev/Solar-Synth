package backend.utils;

class CopyUtil
{
	// thanks stackoverflow
	public static function copy<T>(c:T):T
	{
		var cls:Class<T> = Type.getClass(c);
		var inst:T = Type.createEmptyInstance(cls);
		var fields = Type.getInstanceFields(cls);
		for (field in fields)
		{
			var val:Dynamic = Reflect.field(c, field);
			if (!Reflect.isFunction(val))
				Reflect.setField(inst, field, val);
		}
		return inst;
	}

	public static function copyArray<T>(arr:Array<T>):Array<T>
	{
		if (arr == null)
			return null;

		var result:Array<T> = [];
		for (item in arr)
		{
			result.push(copy(item));
		}
		return result;
	}
}
