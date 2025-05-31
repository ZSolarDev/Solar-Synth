package;

import haxe.ui.HaxeUIApp;
import frontend.MainView;
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
		// TODO: Add config saving on exit
		var app = new HaxeUIApp();
        app.ready(function() {
            app.addComponent(new MainView());
			
            app.start();
        });
	}
}
