package esperhl;

class EsperUtil {
    public static function nativeArrayToArray<T>(arr:NativeArray<T>):Array<T>
		return [for (itm in arr) itm];

	public static function arrayToNativeArray<T>(arr:Array<T>):NativeArray<T>
	{
		var narr:NativeArray<T> = new NativeArray<T>(arr.length);
		for (i in 0...arr.length)
			narr[i] = arr[i];
		return narr;
	}

	public static function f32ArrayToFloatArray(arr:Array<F32>):Array<Float>
		return [for (f32 in arr) f32];

	public static function floatArrayToF32Array(arr:Array<Float>):Array<F32>
		return [for (float in arr) float];

	public static function convertArrayToNF32(array:Array<Float>):NativeArray<F32>
		return arrayToNativeArray(floatArrayToF32Array(array));

	public static function convertArrayFromNF32(array:NativeArray<F32>):Array<Float>
		return f32ArrayToFloatArray(nativeArrayToArray(array));

	public static function convertArrayToNInt(array:Array<Int>):NativeArray<Int>
		return arrayToNativeArray(array);

	public static function convertArrayFromNInt(array:NativeArray<Int>):Array<Int>
		return nativeArrayToArray(array);
}