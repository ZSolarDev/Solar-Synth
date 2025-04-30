package esperhl;

import fft.*;
import hl.F32;
import hl.NativeArray;
import esperhl.EsperUtil.*;

class LibESPER
{
	public static var engineConfig:EngineCfg = new EngineCfg();
	public static var cSamples:CSamples = new CSamples();

	public static function pitchCalcFallback()
	{
		EsperEXT.pitch_calc_fallback();
	}

	public static function specCalc(sample:CSample)
	{
		EsperEXT.spec_calc(convertArrayToNF32(sample.waveform), convertArrayToNInt(sample.pitchDeltas), convertArrayToNInt(sample.pitchMarkers),
			sample.pitchMarkerValidity, convertArrayToNF32(sample.specharm), convertArrayToNF32(sample.avgSpecharm), sample.config.length,
			sample.config.batches, sample.config.pitchLength, sample.config.markerLength, sample.config.pitch, sample.config.isVoiced,
			sample.config.isPlosive, sample.config.useVariance, sample.config.expectedPitch, sample.config.searchRange, sample.config.tempWidth);
	}

	public static function resampleSpecharm(specharm:Array<Float>, avgSpecharm:Array<Float>, steadiness:Array<Float>, output:Array<Float>, spacing:Float,
			startCap:Int, endCap:Int, timing:SegmentTiming)
	{
		EsperEXT.resample_specharm(convertArrayToNF32(specharm), convertArrayToNF32(avgSpecharm), specharm.length, convertArrayToNF32(steadiness), spacing,
			startCap, endCap, convertArrayToNF32(output), timing.start1, timing.start2, timing.start3, timing.end1, timing.end2, timing.end3,
			timing.windowStart, timing.windowEnd, timing.offset);
	}

	public static function resamplePitch(pitchDeltas:Array<Int>, pitch:Float, spacing:Float, startCap:Int, endCap:Int, output:Array<Float>, requiredSize:Int,
			timing:SegmentTiming)
	{
		EsperEXT.resample_pitch(convertArrayToNInt(pitchDeltas), pitchDeltas.length, pitch, spacing, startCap, endCap, convertArrayToNF32(output),
			requiredSize, timing.start1, timing.start2, timing.start3, timing.end1, timing.end2, timing.end3, timing.windowStart, timing.windowEnd,
			timing.offset);
	}

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
