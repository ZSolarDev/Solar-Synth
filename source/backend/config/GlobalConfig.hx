package backend.config;

import haxe.Json;
import sys.FileSystem;
import sys.io.File;

typedef Config =
{
	var resamplerPath:String;
	var consoleVisible:Bool;
}

class GlobalConfig
{
	public static var resamplerPath:String = 'f2resamp/f2resamp64.exe';
	public static var resamplerName(get, null):String;
	public static var resampler(get, null):String;

	// Technical settings
	public static var consoleVisible:Bool = false;

	static function get_resamplerName():String
		return resamplerPath.split('/')[0];

	static function get_resampler():String
		return resamplerPath.split('/')[1];

	public static function saveConfig(path:String = './')
	{
		var config:Config = globalConfigToConfig();
		File.saveContent(path + 'config.json', Json.stringify(config, null, '    '));
	}

	public static function globalConfigToConfig():Config
		return {resamplerPath: resamplerPath, consoleVisible: consoleVisible};

	public static function loadConfig(path:String = './')
	{
		if (!FileSystem.exists(path + 'config.json'))
			return;

		var config:Config = Json.parse(File.getContent(path + 'config.json'));
		loadConfigFromInstance(config);
	}

	public static function loadConfigFromInstance(config:Config)
	{
		resamplerPath = config.resamplerPath;
		consoleVisible = config.consoleVisible;
	}
}
