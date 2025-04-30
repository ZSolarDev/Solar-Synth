package esperhl;

class CSamples
{
	public var length(get, null):Int;

	@:allow(esperhl.LibESPER)
	private function new() {}

	public inline function get(index:Int):CSample
	{
		if (index < 0 || index >= EsperEXT.getc_samples_count()) // Assuming such function exists
			throw 'Sample at index $index does not exist.';
		return new CSample(index);
	}

	public inline function set(index:Int, sample:CSample):Void
	{
		if (index < 0 || index >= EsperEXT.getc_samples_count())
			throw 'Cannot set sample at index $index because it does not exist.';

		EsperEXT.setc_sample_waveform(index, EsperUtil.convertArrayToNF32(sample.waveform));
		EsperEXT.setc_sample_pitch_deltas(index, EsperUtil.convertArrayToNInt(sample.pitchDeltas));
		EsperEXT.setc_sample_pitch_markers(index, EsperUtil.convertArrayToNInt(sample.pitchMarkers));
		EsperEXT.setc_sample_pitch_marker_validity(index, sample.pitchMarkerValidity);
		EsperEXT.setc_sample_specharm(index, EsperUtil.convertArrayToNF32(sample.specharm));
		EsperEXT.setc_sample_avg_specharm(index, EsperUtil.convertArrayToNF32(sample.avgSpecharm));

		EsperEXT.setc_sample_config_length(index, sample.config.length);
		EsperEXT.setc_sample_config_batches(index, sample.config.batches);
		EsperEXT.setc_sample_config_pitch_length(index, sample.config.pitchLength);
		EsperEXT.setc_sample_config_marker_length(index, sample.config.markerLength);
		EsperEXT.setc_sample_config_pitch(index, sample.config.pitch);
		EsperEXT.setc_sample_config_is_voiced(index, sample.config.isVoiced);
		EsperEXT.setc_sample_config_is_plosive(index, sample.config.isPlosive);
		EsperEXT.setc_sample_config_use_variance(index, sample.config.useVariance);
		EsperEXT.setc_sample_config_expected_pitch(index, sample.config.expectedPitch);
		EsperEXT.setc_sample_config_search_range(index, sample.config.searchRange);
		EsperEXT.setc_sample_config_temp_width(index, sample.config.tempWidth);
	}

	public function iterator():CSamplesIterator
		return new CSamplesIterator(this);

	public inline function get_length():Int
		return EsperEXT.getc_samples_count();
}

class CSamplesIterator
{
	var s:CSamples;
	var i:Int;

	public function new(s:CSamples)
	{
		this.s = s;
		i = 0;
	}

	public function hasNext()
		return i < s.length;

	public function next()
		return new CSample(i++);
}
