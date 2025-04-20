package;

import frontend.*;
import lime.app.Application;
import lime.ui.Window;
import openfl.display.Sprite;

class Main extends Sprite
{
	public static var window:Window;

	public function new()
	{
		super();
		window = Application.current.window;
		window.focus();
		addChild(new FlxGame(0, 0, Startup, 60, 60, true, false));
	}
}
