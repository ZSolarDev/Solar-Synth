package libesper;

class CSample
{
	public var index:Int;
	public var waveform(get, set):NativeArray<F32>;
	public var pitchDeltas(get, set):NativeArray<Int>;
	public var pitchMarkers(get, set):NativeArray<Int>;
	public var pitchMarkerValidity(get, set):String;
	public var specharm(get, set):NativeArray<F32>;
	public var avgSpecharm(get, set):NativeArray<F32>;

	public var config:CSampleConfig;

	public function new(index:Int)
	{
		this.index = index;
		config = new CSampleConfig(index);
		waveform = EsperEXT.get_sample_waveform(index);
		pitchDeltas = EsperEXT.get_sample_pitchDeltas(index);
		pitchMarkers = EsperEXT.get_sample_pitchMarkers(index);
		pitchMarkerValidity = EsperEXT.get_sample_pitch_marker_validity(index);
		specharm = EsperEXT.get_sample_specharm(index);
		avgSpecharm = EsperEXT.get_sample_avgSpecharm(index);
	}

	// Non-config setters and getters
	public function get_waveform():NativeArray<F32>
	{
		return EsperEXT.get_sample_waveform(index);
	}

	public function set_waveform(value:NativeArray<F32>):Void
	{
		EsperEXT.set_sample_waveform(index, value);
	}

	public function get_pitchDeltas():NativeArray<Int>
	{
		return EsperEXT.get_sample_pitchDeltas(index);
	}

	public function set_pitchDeltas(value:NativeArray<Int>):Void
	{
		EsperEXT.set_sample_pitchDeltas(index, value);
	}

	public function get_pitchMarkers():NativeArray<Int>
	{
		return EsperEXT.get_sample_pitchMarkers(index);
	}

	public function set_pitchMarkers(value:NativeArray<Int>):Void
	{
		EsperEXT.set_sample_pitchMarkers(index, value);
	}

	public function get_pitchMarkerValidity():String
	{
		return EsperEXT.get_sample_pitch_marker_validity(index);
	}

	public function set_pitchMarkerValidity(value:String):Void
	{
		EsperEXT.set_sample_pitch_marker_validity(index, value);
	}

	public function get_specharm():NativeArray<F32>
	{
		return EsperEXT.get_sample_specharm(index);
	}

	public function set_specharm(value:NativeArray<F32>):Void
	{
		EsperEXT.set_sample_specharm(index, value);
	}

	public function get_avgSpecharm():NativeArray<F32>
	{
		return EsperEXT.get_sample_avgSpecharm(index);
	}

	public function set_avgSpecharm(value:NativeArray<F32>):Void
	{
		EsperEXT.set_sample_avgSpecharm(index, value);
	}

	// Push method to add a sample
	public function push():Void
	{
		// Prepare the data arrays for the push operation
		var waveformData = waveform;
		var pitchDeltasData = pitchDeltas;
		var pitchMarkersData = pitchMarkers;
		var pitchMarkerValidityData = pitchMarkerValidity;
		var specharmData = specharm;
		var avgSpecharmData = avgSpecharm;

		// Push the sample using the extern function
		EsperEXT.push_sample(waveformData, pitchDeltasData, pitchMarkersData, pitchMarkerValidityData, specharmData, avgSpecharmData, config.length,
			config.batches, config.pitchLength, config.markerLength, config.pitch, config.isVoiced, config.isPlosive, config.useVariance,
			config.expectedPitch, config.searchRange, config.tempWidth);
	}
}
