package libesper;

class CSamples
{
	@:allow(libesper.LibESPER)
	private function new() {}

	public inline function get(index:Int):CSample
	{
		if (index < 0 || index >= EsperEXT.get_sample_count()) // Assuming such function exists
			throw 'Sample at index $index does not exist.';
		return new CSample(index);
	}

	public inline function set(index:Int, sample:CSample):Void
	{
		if (index < 0 || index >= EsperEXT.get_sample_count())
			throw 'Cannot set sample at index $index because it does not exist.';

		EsperEXT.set_sample_waveform(index, sample.get_waveform());
		EsperEXT.set_sample_pitchDeltas(index, sample.get_pitchDeltas());
		EsperEXT.set_sample_pitchMarkers(index, sample.get_pitchMarkers());
		EsperEXT.set_sample_pitch_marker_validity(index, sample.get_pitchMarkerValidity());
		EsperEXT.set_sample_specharm(index, sample.get_specharm());
		EsperEXT.set_sample_avgSpecharm(index, sample.get_avgSpecharm());

		EsperEXT.set_sample_config_length(index, sample.get_length());
		EsperEXT.set_sample_config_batches(index, sample.get_batches());
		EsperEXT.set_sample_config_pitch_length(index, sample.get_pitchLength());
		EsperEXT.set_sample_config_marker_length(index, sample.get_markerLength());
		EsperEXT.set_sample_config_pitch(index, sample.get_pitch());
		EsperEXT.set_sample_config_is_voiced(index, sample.get_isVoiced());
		EsperEXT.set_sample_config_is_plosive(index, sample.get_isPlosive());
		EsperEXT.set_sample_config_use_variance(index, sample.get_useVariance());
		EsperEXT.set_sample_config_expected_pitch(index, sample.get_expectedPitch());
		EsperEXT.set_sample_config_search_range(index, sample.get_searchRange());
		EsperEXT.set_sample_config_temp_width(index, sample.get_tempWidth());
	}

	public function iterator():Iterator<CSample>
	{
		return
		{
			var i = 0;
			var max = EsperEXT.get_sample_count(); // You need this implemented
			function hasNext()
				return i < max;
			function next()
				return new CSample(i++);
		};
	}

	public inline function length():Int
		return EsperEXT.get_sample_count();
}
