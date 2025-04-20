package frontend;

import backend.audio.FFT;
import sys.thread.Thread;

class Startup extends FlxState
{
	var bg:FlxSprite;
	var loadingProg:Int = 0;
	var maxLoadingProg:Int = 1;
	var doneLoading:Bool = false;
	var barSpacing:Int = 15;

	override public function create()
	{
		super.create();
		Main.window.focus();
		Main.window.width = 500;
		Main.window.height = 300;
		Main.window.resizable = false;
		Main.window.borderless = true;
		Main.window.x = cast Main.window.display.bounds.width / 2 - (Main.window.width / 2);
		Main.window.y = cast Main.window.display.bounds.height / 2 - (Main.window.height / 2);
		FlxG.resizeGame(500, 300);
		FlxG.scaleMode = new StageSizeScaleMode();
		bg = new FlxSprite(0, 0, "_assets/startup.png");
		bg.setGraphicSize(500, 300);
		bg.updateHitbox();
		add(bg);
		Thread.create(loadSS);
	}

	function loadSS()
	{
		FFT.initialize();
		loadingProg++;
	}

	override public function update(elapsed:Float)
	{
		FlxG.mouse.visible = true;
		if (FlxG.mouse.cursor != null)
			FlxG.mouse.cursor.bitmapData = FlxGraphic.fromAssetKey("_assets/cursor.png").bitmap;
		super.update(elapsed);
		if (loadingProg == maxLoadingProg)
			FlxG.switchState(StartMenu.new);
	}
}
