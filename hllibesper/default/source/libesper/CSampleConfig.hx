package libesper;

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
	public var expectedPitch(get, set):F32;
	public var searchRange(get, set):F32;
	public var tempWidth(get, set):Int;

	public function new(index:Int)
	{
		this.index = index;
	}

	function get_length()
		return EsperEXT.get_sample_config_length(index);

	function set_length(value:Int):Int
	{
		EsperEXT.set_sample_config_length(index, value);
		return value;
	}

	function get_batches():Int
	{
		return EsperEXT.get_sample_config_batches(index);
	}

	function set_batches(value:Int):Int
	{
		EsperEXT.set_sample_config_batches(index, value);
		return value;
	}

	function get_pitchLength():Int
	{
		return EsperEXT.get_sample_config_pitch_length(index);
	}

	function set_pitchLength(value:Int):Int
	{
		EsperEXT.set_sample_config_pitch_length(index, value);
		return value;
	}

	function get_markerLength():Int
	{
		return EsperEXT.get_sample_config_marker_length(index);
	}

	function set_markerLength(value:Int):Int
	{
		EsperEXT.set_sample_config_marker_length(index, value);
		return value;
	}

	function get_pitch():Int
	{
		return EsperEXT.get_sample_config_pitch(index);
	}

	function set_pitch(value:Int):Int
	{
		EsperEXT.set_sample_config_pitch(index, value);
		return value;
	}

	function get_isVoiced():Int
	{
		return EsperEXT.get_sample_config_is_voiced(index);
	}

	function set_isVoiced(value:Int):Int
	{
		EsperEXT.set_sample_config_is_voiced(index, value);
		return value;
	}

	function get_isPlosive():Int
	{
		return EsperEXT.get_sample_config_is_plosive(index);
	}

	function set_isPlosive(value:Int):Int
	{
		EsperEXT.set_sample_config_is_plosive(index, value);
		return value;
	}

	function get_useVariance():Int
	{
		return EsperEXT.get_sample_config_use_variance(index);
	}

	function set_useVariance(value:Int):Int
	{
		EsperEXT.set_sample_config_use_variance(index, value);
		return value;
	}

	function get_expectedPitch():F32
	{
		return EsperEXT.get_sample_config_expected_pitch(index);
	}

	function set_expectedPitch(value:F32):F32
	{
		EsperEXT.set_sample_config_expected_pitch(index, value);
		return value;
	}

	function get_searchRange():F32
	{
		return EsperEXT.get_sample_config_search_range(index);
	}

	function set_searchRange(value:F32):F32
	{
		EsperEXT.set_sample_config_search_range(index, value);
		return value;
	}

	function get_tempWidth():Int
	{
		return EsperEXT.get_sample_config_temp_width(index);
	}

	function set_tempWidth(value:Int):Int
	{
		EsperEXT.set_sample_config_temp_width(index, value);
		return value;
	}
}
