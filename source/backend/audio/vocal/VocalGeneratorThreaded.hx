package backend.audio.vocal;

import openfl.media.Sound;

class VocalGeneratorThreaded
{
	var generators:Map<String, VocalGenerator> = new Map();
	var generated:Bool = false;
	var result:Sound;
}
