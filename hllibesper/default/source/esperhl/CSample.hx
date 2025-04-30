package esperhl;

import esperhl.CSampleConfig.CSampleConfigPushable;

class CSample
{
	public var index:Int;
	public var waveform(get, set):Array<Float>;
	public var pitchDeltas(get, set):Array<Int>;
	public var pitchMarkers(get, set):Array<Int>;
	public var pitchMarkerValidity(get, set):String;
	public var specharm(get, set):Array<Float>;
	public var avgSpecharm(get, set):Array<Float>;

	public var config:CSampleConfig;

	public function new(index:Int)
	{
		this.index = index;
		config = new CSampleConfig(index);
	}

	// Non-config setters and getters
	function get_waveform():Array<Float>
		return EsperUtil.convertArrayFromNF32(EsperEXT.getc_sample_waveform(index));

	function set_waveform(value:Array<Float>):Array<Float>
	{
		EsperEXT.setc_sample_waveform(index, EsperUtil.convertArrayToNF32(value));
		return value;
	}

	function get_pitchDeltas():Array<Int>
		return EsperUtil.convertArrayFromNInt(EsperEXT.getc_sample_pitch_deltas(index));

	function set_pitchDeltas(value:Array<Int>):Array<Int>
	{
		EsperEXT.setc_sample_pitch_deltas(index, EsperUtil.convertArrayToNInt(value));
		return value;
	}

	function get_pitchMarkers():Array<Int>
		return EsperUtil.convertArrayFromNInt(EsperEXT.getc_sample_pitch_markers(index));

	function set_pitchMarkers(value:Array<Int>):Array<Int>
	{
		EsperEXT.setc_sample_pitch_markers(index, EsperUtil.convertArrayToNInt(value));
		return value;
	}

	function get_pitchMarkerValidity():String
		return EsperEXT.getc_sample_pitch_marker_validity(index);

	function set_pitchMarkerValidity(value:String):String
	{
		EsperEXT.setc_sample_pitch_marker_validity(index, value);
		return value;
	}

	function get_specharm():Array<Float>
		return EsperUtil.convertArrayFromNF32(EsperEXT.getc_sample_specharm(index));

	function set_specharm(value:Array<Float>):Array<Float>
	{
		EsperEXT.setc_sample_specharm(index, EsperUtil.convertArrayToNF32(value));
		return value;
	}

	function get_avgSpecharm():Array<Float>
		return EsperUtil.convertArrayFromNF32(EsperEXT.getc_sample_avg_specharm(index));

	function set_avgSpecharm(value:Array<Float>):Array<Float>
	{
		EsperEXT.setc_sample_avg_specharm(index, EsperUtil.convertArrayToNF32(value));
		return value;
	}

	public function push()
	{
		var waveformData = EsperUtil.convertArrayToNF32(waveform);
		var pitchDeltasData = EsperUtil.convertArrayToNInt(pitchDeltas);
		var pitchMarkersData = EsperUtil.convertArrayToNInt(pitchMarkers);
		var pitchMarkerValidityData = pitchMarkerValidity;
		var specharmData = EsperUtil.convertArrayToNF32(specharm);
		var avgSpecharmData = EsperUtil.convertArrayToNF32(avgSpecharm);

		EsperEXT.pushc_sample(waveformData, pitchDeltasData, pitchMarkersData, pitchMarkerValidityData, specharmData, avgSpecharmData, config.length,
			config.batches, config.pitchLength, config.markerLength, config.pitch, config.isVoiced, config.isPlosive, config.useVariance,
			config.expectedPitch, config.searchRange, config.tempWidth);
	}
}

class CSamplePushable
{
	public var waveform:Array<Float>;
	public var pitchDeltas:Array<Int>;
	public var pitchMarkers:Array<Int>;
	public var pitchMarkerValidity:String;
	public var specharm:Array<Float>;
	public var avgSpecharm:Array<Float>;

	public var config:CSampleConfigPushable;

	public function new(waveform:Array<Float>, pitchDeltas:Array<Int>, pitchMarkers:Array<Int>, pitchMarkerValidity:String, specharm:Array<Float>,
			avgSpecharm:Array<Float>)
	{
		this.waveform = waveform;
		this.pitchDeltas = pitchDeltas;
		this.pitchMarkers = pitchMarkers;
		this.pitchMarkerValidity = pitchMarkerValidity;
		this.specharm = specharm;
		this.avgSpecharm = avgSpecharm;
	}

	public function push():CSample
	{
		var waveformData = EsperUtil.convertArrayToNF32(waveform);
		var pitchDeltasData = EsperUtil.convertArrayToNInt(pitchDeltas);
		var pitchMarkersData = EsperUtil.convertArrayToNInt(pitchMarkers);
		var pitchMarkerValidityData = pitchMarkerValidity;
		var specharmData = EsperUtil.convertArrayToNF32(specharm);
		var avgSpecharmData = EsperUtil.convertArrayToNF32(avgSpecharm);

		EsperEXT.pushc_sample(waveformData, pitchDeltasData, pitchMarkersData, pitchMarkerValidityData, specharmData, avgSpecharmData, config.length,
			config.batches, config.pitchLength, config.markerLength, config.pitch, config.isVoiced, config.isPlosive, config.useVariance,
			config.expectedPitch, config.searchRange, config.tempWidth);
		return new CSample(EsperEXT.getc_samples_count());
	}
}
