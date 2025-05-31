package;

import backend.config.GlobalConfig;
import frontend.*;
import lime.app.Application;
import lime.ui.Window;
import openfl.display.Sprite;

class Main extends Sprite
{
	public static var window:Window;
	public static var application:Application;

	public function new()
	{
		super();
		application = Application.current;
		application.onExit.add((_) ->
		{
			GlobalConfig.saveConfig();
		});
		window = application.window;
		window.focus();
	}
}
