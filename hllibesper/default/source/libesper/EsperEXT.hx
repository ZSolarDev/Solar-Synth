package libesper;

import hl.F32;
import hl.NativeArray;

class EsperEXT
{
	@:hlNative('libesper') public static function pitch_calc_fallback()
		return;

	@:hlNative("libesper")
	public static function spec_calc(waveform:NativeArray<F32>, pitchDeltas:NativeArray<Int>, pitchMarkers:NativeArray<Int>, pitchMarkerValidity:String,
			specharm:NativeArray<F32>, avgSpecharm:NativeArray<F32>, length:Int, batches:Int, pitchLength:Int, markerLength:Int, pitch:Int, isVoiced:Int,
			isPlosive:Int, useVariance:Int, expectedPitch:F32, searchRange:F32, tempWidth:Int)
		return;

	@:hlNative("libesper")
	public static function resample_specharm(specharm:NativeArray<F32>, avgSpecharm:NativeArray<F32>, length:Int, steadiness:NativeArray<F32>, spacing:F32,
			startCap:Int, endCap:Int, output:NativeArray<F32>, start1:Int, start2:Int, start3:Int, end1:Int, end2:Int, end3:Int, windowStart:Int,
			windowEnd:Int, offset:Int)
		return;

	@:hlNative("libesper")
	public static function resample_pitch(pitchDeltas:NativeArray<Int>, length:Int, pitch:F32, spacing:F32, startCap:Int, endCap:Int, output:NativeArray<F32>,
			requiredSize:Int, start1:Int, start2:Int, start3:Int, end1:Int, end2:Int, end3:Int, windowStart:Int, windowEnd:Int, offset:Int)
		return;

	@:hlNative("libesper")
	public static function apply_breathiness(specharm:NativeArray<F32>, breathiness:NativeArray<F32>, length:Int)
		return;

	@:hlNative("libesper")
	public static function pitch_shift(specharm:NativeArray<F32>, srcPitch:NativeArray<F32>, tgtPitch:NativeArray<F32>, formantShift:NativeArray<F32>,
			breathiness:NativeArray<F32>, length:Int)
		return;

	@:hlNative("libesper")
	public static function apply_dynamics(specharm:NativeArray<F32>, dynamics:NativeArray<F32>, pitch:NativeArray<F32>, length:Int)
		return;

	@:hlNative("libesper")
	public static function apply_brightness(specharm:NativeArray<F32>, brightness:NativeArray<F32>, length:Int)
		return;

	@:hlNative("libesper")
	public static function apply_growl(specharm:NativeArray<F32>, growl:NativeArray<F32>, lfoPhase:NativeArray<F32>, length:Int)
		return;

	@:hlNative("libesper")
	public static function apply_roughness(specharm:NativeArray<F32>, roughness:NativeArray<F32>, length:Int)
		return;

	@:hlNative("libesper")
	public static function render_unvoiced(specharm:NativeArray<F32>, target:NativeArray<F32>, length:Int)
		return;

	@:hlNative("libesper")
	public static function render_voiced(specharm:NativeArray<F32>, pitch:NativeArray<F32>, phase:NativeArray<F32>, target:NativeArray<F32>, length:Int)
		return;

	@:hlNative("libesper")
	public static function render(specharm:NativeArray<F32>, pitch:NativeArray<F32>, phase:NativeArray<F32>, target:NativeArray<F32>, length:Int)
		return;

	// Sample Rate

	@:hlNative("libesper")
	public static function get_sample_rate():Int
		return 0;

	@:hlNative("libesper")
	public static function set_sample_rate(sampleRate:Int)
		return;

	// Tick Rate

	@:hlNative("libesper")
	public static function get_tick_rate():Int
		return 0;

	@:hlNative("libesper")
	public static function set_tick_rate(tickRate:Int)
		return;

	// Batch Size

	@:hlNative("libesper")
	public static function get_batch_size():Int
		return 0;

	@:hlNative("libesper")
	public static function set_batch_size(batchSize:Int)
		return;

	// Triple Batch Size

	@:hlNative("libesper")
	public static function get_triple_batch_size():Int
		return 0;

	@:hlNative("libesper")
	public static function set_triple_batch_size(tripleBatchSize:Int)
		return;

	// Half Triple Batch Size

	@:hlNative("libesper")
	public static function get_half_triple_batch_size():Int
		return 0;

	@:hlNative("libesper")
	public static function set_half_triple_batch_size(halfTripleBatchSize:Int)
		return;

	// Number of Harmonics

	@:hlNative("libesper")
	public static function getn_harmonics():Int
		return 0;

	@:hlNative("libesper")
	public static function setn_harmonics(nHarmonics:Int)
		return;

	// Half Harmonics

	@:hlNative("libesper")
	public static function get_half_harmonics():Int
		return 0;

	@:hlNative("libesper")
	public static function set_half_harmonics(halfHarmonics:Int)
		return;

	// Frame Size

	@:hlNative("libesper")
	public static function get_frame_size():Int
		return 0;

	@:hlNative("libesper")
	public static function set_frame_size(frameSize:Int)
		return;

	// Breathiness Compression Premultiplier

	@:hlNative("libesper")
	public static function get_bre_comp_premul():F32
		return 0.0;

	@:hlNative("libesper")
	public static function set_bre_comp_premul(breCompPremul:F32)
		return;

	@:hlNative('libesper')
	public static function getc_sample_waveform(index:Int):NativeArray<F32>
		return cast [];

	@:hlNative('libesper')
	public static function getc_sample_pitch_deltas(index:Int):hl.NativeArray<Int>
		return cast [];

	@:hlNative('libesper')
	public static function getc_sample_pitch_markers(index:Int):hl.NativeArray<Int>
		return cast [];

	@:hlNative('libesper')
	public static function getc_sample_pitch_marker_validity(index:Int):String
		return '';

	@:hlNative('libesper')
	public static function getc_sample_specharm(index:Int):NativeArray<F32>
		return cast [];

	@:hlNative('libesper')
	public static function getc_sample_avg_specharm(index:Int):NativeArray<F32>
		return cast [];

	@:hlNative('libesper')
	public static function getc_sample_config_length(index:Int):Int
		return 0;

	@:hlNative('libesper')
	public static function getc_sample_config_batches(index:Int):Int
		return 0;

	@:hlNative('libesper')
	public static function getc_sample_config_pitch_length(index:Int):Int
		return 0;

	@:hlNative('libesper')
	public static function getc_sample_config_marker_length(index:Int):Int
		return 0;

	@:hlNative('libesper')
	public static function getc_sample_config_pitch(index:Int):Int
		return 0;

	@:hlNative('libesper')
	public static function getc_sample_config_is_voiced(index:Int):Int
		return 0;

	@:hlNative('libesper')
	public static function getc_sample_config_is_plosive(index:Int):Int
		return 0;

	@:hlNative('libesper')
	public static function getc_sample_config_use_variance(index:Int):Int
		return 0;

	@:hlNative('libesper')
	public static function getc_sample_config_expected_pitch(index:Int):F32
		return 0.0;

	@:hlNative('libesper')
	public static function getc_sample_config_search_range(index:Int):F32
		return 0.0;

	@:hlNative('libesper')
	public static function getc_sample_config_temp_width(index:Int):Int
		return 0;

	@:hlNative('libesper')
	public static function getc_samples_count():Int
		return 0;

	@:hlNative('libesper')
	public static function setc_sample_waveform(index:Int, waveform:NativeArray<F32>)
		return;

	@:hlNative('libesper')
	public static function setc_sample_pitch_deltas(index:Int, pitchDeltas:hl.NativeArray<Int>)
		return;

	@:hlNative('libesper')
	public static function setc_sample_pitch_markers(index:Int, pitchMarkers:hl.NativeArray<Int>)
		return;

	@:hlNative('libesper')
	public static function setc_sample_pitch_marker_validity(index:Int, validity:String)
		return;

	@:hlNative('libesper')
	public static function setc_sample_specharm(index:Int, specharm:NativeArray<F32>)
		return;

	@:hlNative('libesper')
	public static function setc_sample_avg_specharm(index:Int, avgSpecharm:NativeArray<F32>)
		return;

	@:hlNative('libesper')
	public static function setc_sample_config_length(index:Int, length:Int)
		return;

	@:hlNative('libesper')
	public static function setc_sample_config_batches(index:Int, batches:Int)
		return;

	@:hlNative('libesper')
	public static function setc_sample_config_pitch_length(index:Int, pitchLength:Int)
		return;

	@:hlNative('libesper')
	public static function setc_sample_config_marker_length(index:Int, markerLength:Int)
		return;

	@:hlNative('libesper')
	public static function setc_sample_config_pitch(index:Int, pitch:Int)
		return;

	@:hlNative('libesper')
	public static function setc_sample_config_is_voiced(index:Int, isVoiced:Int)
		return;

	@:hlNative('libesper')
	public static function setc_sample_config_is_plosive(index:Int, isPlosive:Int)
		return;

	@:hlNative('libesper')
	public static function setc_sample_config_use_variance(index:Int, useVariance:Int)
		return;

	@:hlNative('libesper')
	public static function setc_sample_config_expected_pitch(index:Int, expectedPitch:F32)
		return;

	@:hlNative('libesper')
	public static function setc_sample_config_search_range(index:Int, searchRange:F32)
		return;

	@:hlNative('libesper')
	public static function setc_sample_config_temp_width(index:Int, tempWidth:Int)
		return;

	@:hlNative('libesper')
	public static function pushc_sample(waveform:NativeArray<F32>, pitchDeltas:hl.NativeArray<Int>, pitchMarkers:hl.NativeArray<Int>,
			pitchMarkerValidity:String, specharm:NativeArray<F32>, avgSpecharm:NativeArray<F32>, length:Int, batches:Int, pitchLength:Int, markerLength:Int,
			pitch:Int, isVoiced:Int, isPlosive:Int, useVariance:Int, expectedPitch:F32, searchRange:F32, tempWidth:Int)
		return;

	@:hlNative('libesper')
	public static function clearc_samples()
		return;
}
