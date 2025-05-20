package backend.utils;

import Lambda;
import StringTools;
import sys.FileSystem;
import sys.io.File;

// This came from hxIni, had to modify some things cause the original wouldn't compile.

/**
 * INI section (like [Program] or [Settings]). Used to organize variables. An Ini object is composed by IniSections.
 */
typedef IniSection = Map<String, String>;

/**
 * A Composition of IniSection. The main object of this library, and it's used to represent the INI data.
 *
 * Data may be accessed this way:
 *
 * <code>var ini: Ini = IniManager.LoadFromString("g="blablabla"\n[test]\na = 5\nb=6");</code><br>
 * <code>trace(ini["Global"]["g"]) // Outputs "blablabla"</code><br>
 * <code>trace(ini["test"]["a"])   // Outputs "5"</code><br>
 * <code>trace(ini["test"]["b"])   // Outputs "6"</code><br>
 */
typedef Ini = Map<String, IniSection>;

/**
 * Primary INI manager class. Used for reading and writing INI files.
 * For data format, checkout http://en.wikipedia.org/wiki/INI_file
 * Also, check out http://stackoverflow.com/questions/3870019/javascript-parser-for-a-string-which-contains-ini-data
 * @author Wikiti
 */
class IniManager
{
	/**
	 * Global section name ("Global").
	 */
	public static inline var GLOBAL_SECTION:String = "Global";

	private function new() {}

	/**
	 * Read INI data from file.
	 *
	 * @param file File to be readed.
	 * @return An Ini object if reading and parsing work. "null" will be returned if the reading fails.
	 */
	static public function loadFromFile(file:String):Ini
	{
		if (!FileSystem.exists(file))
			return null;

		return loadFromString(File.getContent(file));
	}

	/**
	 * Read INI data from string.
	 * @param data String to be loaded.
	 * @return An Ini object if reading and parsing work. An empty object will be returned if the string is empty.
	 */
	static public function loadFromString(data:String):Ini
	{
		// http://stackoverflow.com/questions/3870019/javascript-parser-for-a-string-which-contains-ini-data

		// Regex
		var regexp = {
			section: ~/^\s*\[\s*([^\]]*)\s*\]\s*$/,
			param: ~/^([^=]+)=(.*)$/,
			comment: ~/^;.*$/,
			blank: ~/^[ \n\r\t]$/
		};

		var ini:Ini = new Ini();
		ini[GLOBAL_SECTION] = new IniSection();

		var splitter = ~/\r\n|\r|\n/g;
		var lines = splitter.split(data);
		var section:String = GLOBAL_SECTION;

		// Parse
		for (line in lines)
		{
			line = StringTools.trim(line);

			// Comment or blank line
			if (line.length == 0 || regexp.comment.match(line) || regexp.blank.match(line))
			{
				continue;
			}
			// Parameter (variable)
			else if (regexp.param.match(line))
			{
				var key = StringTools.trim(regexp.param.matched(1));
				var value = StringTools.trim(regexp.param.matched(2));
				ini[section][key] = value;
			}
			// Section (new)
			else if (regexp.section.match(line))
			{
				// Crear sección si NO existe
				section = StringTools.trim(regexp.section.matched(1));
				if (ini[section] == null)
					ini[section] = new IniSection();
			}
		}

		return ini;
	}

	/**
	 * Transform the ini object to an string and writes it to a file.
	 * @param ini Ini object to write to file.
	 * @param file File to be writed.
	 */
	static public function writeToFile(ini:Ini, file:String):Void
	{
		var file = File.write(file);
		file.writeString(toString(ini));
		file.close();
	}

	/**
	 * Transform the ini object to an string.
	 * @param ini Ini object to transform.
	 * @return String representation of the ini object.
	 */
	static public function toString(ini:Ini):String
	{
		var result_str:String = "";
		if (ini == null)
			return result_str;

		for (section in ini.keys())
		{
			if (Lambda.count(ini[section]) == 0)
				continue;

			if (section != "Global")
				result_str += "[" + section + "]";
			result_str += "\n";

			for (param in ini[section].keys())
			{
				result_str += param + "=" + ini[section][param] + "\n";
			}
			result_str += "\n";
		}

		return StringTools.trim(result_str);
	}
}
