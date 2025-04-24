package libesper;

class EngineCfg
{
	public var sampleRate(get, set):Int;
	public var tickRate(get, set):Int;
	public var batchSize(get, set):Int;
	public var tripleBatchSize(get, set):Int;
	public var halfTripleBatchSize(get, set):Int;
	public var nHarmonics(get, set):Int;
	public var halfHarmonics(get, set):Int;
	public var frameSize(get, set):Int;
	public var breCompPremul(get, set):Float;

	@:allow(libesper.LibESPER)
	private function new()
	{
		sampleRate = EsperEXT.get_sample_rate();
		tickRate = EsperEXT.get_tick_rate();
		batchSize = EsperEXT.get_batch_size();
		tripleBatchSize = EsperEXT.get_triple_batch_size();
		halfTripleBatchSize = EsperEXT.get_half_triple_batch_size();
		nHarmonics = EsperEXT.getn_harmonics();
		halfHarmonics = EsperEXT.get_half_harmonics();
		frameSize = EsperEXT.get_frame_size();
		breCompPremul = EsperEXT.get_bre_comp_premul();
	}

	function get_sampleRate():Int
		return EsperEXT.get_sample_rate();

	function set_sampleRate(v:Int):Int
	{
		EsperEXT.set_sample_rate(v);
		return v;
	}

	function get_tickRate():Int
		return EsperEXT.get_tick_rate();

	function set_tickRate(v:Int):Int
	{
		EsperEXT.set_tick_rate(v);
		return v;
	}

	function get_batchSize():Int
		return EsperEXT.get_batch_size();

	function set_batchSize(v:Int):Int
	{
		EsperEXT.set_batch_size(v);
		return v;
	}

	function get_tripleBatchSize():Int
		return EsperEXT.get_triple_batch_size();

	function set_tripleBatchSize(v:Int):Int
	{
		EsperEXT.set_triple_batch_size(v);
		return v;
	}

	function get_halfTripleBatchSize():Int
		return EsperEXT.get_half_triple_batch_size();

	function set_halfTripleBatchSize(v:Int):Int
	{
		EsperEXT.set_half_triple_batch_size(v);
		return v;
	}

	function get_nHarmonics():Int
		return EsperEXT.getn_harmonics();

	function set_nHarmonics(v:Int):Int
	{
		EsperEXT.setn_harmonics(v);
		return v;
	}

	function get_halfHarmonics():Int
		return EsperEXT.get_half_harmonics();

	function set_halfHarmonics(v:Int):Int
	{
		EsperEXT.set_half_harmonics(v);
		return v;
	}

	function get_frameSize():Int
		return EsperEXT.get_frame_size();

	function set_frameSize(v:Int):Int
	{
		EsperEXT.set_frame_size(v);
		return v;
	}

	function get_breCompPremul():Float
		return EsperEXT.get_bre_comp_premul();

	function set_breCompPremul(v:Float):Float
	{
		EsperEXT.set_bre_comp_premul(v);
		return v;
	}
}
