package backend.utils;

import backend.data.Voicebank;

using StringTools;

class VBLoader
{
	public static function loadVoicebankFromFolder(folderPath:String):Voicebank
	{
		var voicebank:Voicebank = {
			samples: new Map<String, String>(),
			icon: '',
			name: '',
			description: '',
			singer: '',
			credits: [],
			language: '',
			consonantSampleStart: 0,
			sampleStart: 0,
			mouth: false,
			breaths: false,
			mouthBreath: false,
			power: false,
			mouthPower: false,
			soft: false,
			mouthSoft: false,
			breathSamples: 0,
            fileName: folderPath.split('/')[1]
		};
		return voicebank;
	}
}
