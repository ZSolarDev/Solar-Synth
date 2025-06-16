package backend.utils;

import backend.data.Voicebank;
import backend.utils.IniParser.Ini;
import backend.utils.IniParser.IniManager;
import sys.FileSystem;

using StringTools;

class VoicebankUtil
{
	public static var blankVoicebank(get, null):Voicebank;

	static function get_blankVoicebank():Voicebank
		return {
			samples: new Map<String, String>(),
			icon: '',
			name: '',
			description: '',
			singer: '',
			credits: [],
			language: '',
			consonantSampleStart: 0,
			sampleStart: 0,
			breaths: false,
			power: false,
			soft: false,
			breathSamples: 0,
			fileName: ''
		};

	public static function loadVoicebankFromFolder(folderPath:String):Voicebank
	{
		inline function stringToBool(s:String):Bool
			return s.trim() == 'true';

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
			breaths: false,
			power: false,
			soft: false,
			breathSamples: 0,
			fileName: folderPath.split('/')[1]
		};
		var config:Ini = IniManager.loadFromFile('$folderPath/config.ini');
		// let's start from the top.
		if (config != null)
		{
			// the character(very simple)
			var vbCharacter = config['Character'];
			voicebank.name = vbCharacter['name'];
			voicebank.description = vbCharacter['description'];
			voicebank.singer = vbCharacter['singer'];
			voicebank.credits = vbCharacter['credits'].trim().replace(', ', ',').split(',');
			voicebank.icon = vbCharacter['icon'];
			// voicebank settings (also very simple)
			var vbCharacter = config['Voicebank'];
			voicebank.language = vbCharacter['language'];
			voicebank.sampleStart = Std.parseFloat(vbCharacter['sampleStart']);
			voicebank.consonantSampleStart = Std.parseFloat(vbCharacter['consonantSampleStart']);
			// sample stuff(eh not that complicated)
			var finalSamples:Map<String, String> = new Map();
			var variationsAvailable = ['normal', 'breaths', 'power', 'soft'];
			var vbParams = config['Voicebank Parameters'];
			for (param in vbParams.keys())
			{
				if (param != 'breathSamples')
				{
					var paramAvailable = stringToBool(vbParams[param]);
					Reflect.setProperty(voicebank, param, paramAvailable);
					if (variationsAvailable.contains(param) && !paramAvailable)
						variationsAvailable.remove(param);
				}
			}
			for (variation in variationsAvailable)
			{
				var samples = FileSystem.readDirectory('$folderPath/$variation');
				for (sample in samples)
				{
					if (sample.endsWith('.wav'))
						finalSamples.set(variation != 'normal' ? '$variation//${sample.replace('.wav', ' ').rtrim()}' : sample.replace('.wav', ' ').rtrim(),
							'$folderPath/$variation/$sample');
				}
			}
			var breaths:Int = Std.parseInt(vbParams['breathSamples']);
			for (i in 1...breaths + 1)
				finalSamples.set('b$i', '$folderPath/breath/$i.wav');
			voicebank.samples = finalSamples;
		}
		return voicebank;
	}

	public static function getVoicebanks():Array<{name:String, initialized:Bool}>
	{
		var res:Array<{name:String, initialized:Bool}> = [];
		var voicebanks = FileSystem.readDirectory('./voicebanks');
		for (voicebank in voicebanks)
		{
			res.push({
				name: voicebank,
				initialized: FileSystem.exists('./voicebanks/$voicebank/_init')
			});
		}
		return res;
	}
}
