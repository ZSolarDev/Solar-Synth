package libesper;

import hl.F32;
import hl.NativeArray;

// TODO: ADD get_sample_count EXTERN FOR CSAMPLES
class LibESPER
{
	public static var engineConfig:EngineCfg = new EngineCfg();
	public static var cSamples:CSamples = new CSamples();

	static function nativeArrayToArray<T>(arr:NativeArray<T>):Array<T>
		return [for (itm in arr) itm];

	static function arrayToNativeArray<T>(arr:Array<T>):NativeArray<T>
	{
		var narr:NativeArray<T> = new NativeArray<T>(arr.length);
		for (i in 0...arr.length)
			narr[i] = arr[i];
		return narr;
	}

	static function f32ArrayToFloatArray(arr:Array<F32>):Array<Float>
		return [for (f32 in arr) f32];

	static function floatArrayToF32Array(arr:Array<Float>):Array<F32>
		return [for (float in arr) float];

	static function convertArrayToNF32(array:Array<Float>):NativeArray<F32>
		return arrayToNativeArray(floatArrayToF32Array(array));

	static function convertArrayFromNF32(array:NativeArray<F32>):Array<Float>
		return f32ArrayToFloatArray(nativeArrayToArray(array));

	static function convertArrayToNInt(array:Array<Int>):NativeArray<Int>
		return arrayToNativeArray(array);

	static function convertArrayFromNInt(array:NativeArray<Int>):Array<Int>
		return nativeArrayToArray(array);

	public static function applyBreathiness(specharm:Array<Float>, breathiness:Array<Float>)
	{
		EsperEXT.apply_breathiness(convertArrayToNF32(specharm), convertArrayToNF32(breathiness), specharm.length);
	}

	public static function pitchShift(specharm:Array<Float>, srcPitch:Array<Float>, tgtPitch:Array<Float>, formantShift:Array<Float>, breathiness:Array<Float>)
	{
		EsperEXT.pitch_shift(convertArrayToNF32(specharm), convertArrayToNF32(srcPitch), convertArrayToNF32(tgtPitch), convertArrayToNF32(formantShift),
			convertArrayToNF32(breathiness), specharm.length);
	}

	public static function applyDynamics(specharm:Array<Float>, dynamics:Array<Float>, pitch:Array<Float>)
	{
		EsperEXT.apply_dynamics(convertArrayToNF32(specharm), convertArrayToNF32(dynamics), convertArrayToNF32(pitch), specharm.length);
	}

	public static function applyBrightness(specharm:Array<Float>, brightness:Array<Float>)
	{
		EsperEXT.apply_brightness(convertArrayToNF32(specharm), convertArrayToNF32(brightness), specharm.length);
	}

	public static function applyGrowl(specharm:Array<Float>, growl:Array<Float>, lfoPhase:Array<Float>)
	{
		EsperEXT.apply_growl(convertArrayToNF32(specharm), convertArrayToNF32(growl), convertArrayToNF32(lfoPhase), specharm.length);
	}

	public static function applyRoughness(specharm:Array<Float>, roughness:Array<Float>)
	{
		EsperEXT.apply_roughness(convertArrayToNF32(specharm), convertArrayToNF32(roughness), specharm.length);
	}

	public static function renderUnvoiced(specharm:Array<Float>, target:Array<Float>)
	{
		EsperEXT.render_unvoiced(convertArrayToNF32(specharm), convertArrayToNF32(target), specharm.length);
	}

	public static function renderVoiced(specharm:Array<Float>, pitch:Array<Float>, phase:Array<Float>, target:Array<Float>)
	{
		EsperEXT.render_voiced(convertArrayToNF32(specharm), convertArrayToNF32(pitch), convertArrayToNF32(phase), convertArrayToNF32(target), specharm.length);
	}

	public static function render(specharm:Array<Float>, pitch:Array<Float>, phase:Array<Float>, target:Array<Float>)
	{
		EsperEXT.render(convertArrayToNF32(specharm), convertArrayToNF32(pitch), convertArrayToNF32(phase), convertArrayToNF32(target), specharm.length);
	}
}
