package;

import fft.*;
import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();
		FFT.initialize();
		addChild(new FlxGame(0, 0, PlayState));
	}
}
