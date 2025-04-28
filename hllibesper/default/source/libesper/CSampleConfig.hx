package libesper;

import hl.*;

class CSampleConfig
{
	public var index:Int;

	public var length(get, set):Int;
	public var batches(get, set):Int;
	public var pitchLength(get, set):Int;
	public var markerLength(get, set):Int;
	public var pitch(get, set):Int;
	public var isVoiced(get, set):Int;
	public var isPlosive(get, set):Int;
	public var useVariance(get, set):Int;
	public var expectedPitch(get, set):Float;
	public var searchRange(get, set):Float;
	public var tempWidth(get, set):Int;

	public function new(index:Int)
	{
		this.index = index;
	}

	function get_length()
		return EsperEXT.getc_sample_config_length(index);

	function set_length(value:Int):Int
	{
		EsperEXT.setc_sample_config_length(index, value);
		return value;
	}

	function get_batches():Int
		return EsperEXT.getc_sample_config_batches(index);

	function set_batches(value:Int):Int
	{
		EsperEXT.setc_sample_config_batches(index, value);
		return value;
	}

	function get_pitchLength():Int
		return EsperEXT.getc_sample_config_pitch_length(index);

	function set_pitchLength(value:Int):Int
	{
		EsperEXT.setc_sample_config_pitch_length(index, value);
		return value;
	}

	function get_markerLength():Int
		return EsperEXT.getc_sample_config_marker_length(index);

	function set_markerLength(value:Int):Int
	{
		EsperEXT.setc_sample_config_marker_length(index, value);
		return value;
	}

	function get_pitch():Int
		return EsperEXT.getc_sample_config_pitch(index);

	function set_pitch(value:Int):Int
	{
		EsperEXT.setc_sample_config_pitch(index, value);
		return value;
	}

	function get_isVoiced():Int
		return EsperEXT.getc_sample_config_is_voiced(index);

	function set_isVoiced(value:Int):Int
	{
		EsperEXT.setc_sample_config_is_voiced(index, value);
		return value;
	}

	function get_isPlosive():Int
		return EsperEXT.getc_sample_config_is_plosive(index);

	function set_isPlosive(value:Int):Int
	{
		EsperEXT.setc_sample_config_is_plosive(index, value);
		return value;
	}

	function get_useVariance():Int
		return EsperEXT.getc_sample_config_use_variance(index);

	function set_useVariance(value:Int):Int
	{
		EsperEXT.setc_sample_config_use_variance(index, value);
		return value;
	}

	function get_expectedPitch():Float
		return EsperEXT.getc_sample_config_expected_pitch(index);

	function set_expectedPitch(value:Float):Float
	{
		EsperEXT.setc_sample_config_expected_pitch(index, value);
		return value;
	}

	function get_searchRange():Float
		return EsperEXT.getc_sample_config_search_range(index);

	function set_searchRange(value:Float):Float
	{
		EsperEXT.setc_sample_config_search_range(index, value);
		return value;
	}

	function get_tempWidth():Int
		return EsperEXT.getc_sample_config_temp_width(index);

	function set_tempWidth(value:Int):Int
	{
		EsperEXT.setc_sample_config_temp_width(index, value);
		return value;
	}
}

class CSampleConfigPushable
{
	public var length:Int;
	public var batches:Int;
	public var pitchLength:Int;
	public var markerLength:Int;
	public var pitch:Int;
	public var isVoiced:Int;
	public var isPlosive:Int;
	public var useVariance:Int;
	public var expectedPitch:Float;
	public var searchRange:Float;
	public var tempWidth:Int;

	public function new(length:Int, batches:Int, pitchLength:Int, markerLength:Int, pitch:Int, isVoiced:Int, isPlosive:Int, useVariance:Int,
			expectedPitch:Float, searchRange:Float, tempWidth:Int)
	{
		this.length = length;
		this.batches = batches;
		this.pitchLength = pitchLength;
		this.markerLength = markerLength;
		this.pitch = pitch;
		this.isVoiced = isVoiced;
		this.isPlosive = isPlosive;
		this.useVariance = useVariance;
		this.expectedPitch = expectedPitch;
		this.searchRange = searchRange;
		this.tempWidth = tempWidth;
	}
}
