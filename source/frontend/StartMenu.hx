package frontend;

import frontend.startmenu.*;

class StartMenu extends FlxState
{
	var overlay:FlxSprite;
	var tabColliders:Array<FlxSprite> = [];
	var tabCam:FlxCamera = null;

	var tabs:Map<String, Class<Tab>> = ['projects' => ProjectsTab, 'settings' => SettingsTab, 'voicebanks' => VoicebanksTab];

	override public function create()
	{
		super.create();
		Main.window.focus();
		Main.window.width = 400;
		Main.window.height = 512;
		Main.window.borderless = false;
		Main.window.x = cast Main.window.display.bounds.width / 2 - (Main.window.width / 2);
		Main.window.y = cast Main.window.display.bounds.height / 2 - (Main.window.height / 2);
		FlxG.resizeGame(400, 512);
		tabCam = new ProjectsTab(18, 203, this);
		FlxG.cameras.add(tabCam, false);
		overlay = new FlxSprite(0, 0, '_assets/UI-0.png');
		overlay.setGraphicSize(400, 512);
		overlay.updateHitbox();
		add(overlay);
		for (i in 0...3)
			tabColliders.push(new FlxSprite(15 + i * 123, 180, '').makeGraphic(123, 23, 0x00000000));
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		FlxG.mouse.visible = true;
		if (FlxG.mouse.cursor != null)
			FlxG.mouse.cursor.bitmapData = FlxGraphic.fromAssetKey("_assets/cursor.png").bitmap;
		var changedTab = false;
		if (FlxG.mouse.justPressed)
		{
			for (i in 0...tabColliders.length)
			{
				var collider = tabColliders[i];
				if (FlxG.mouse.overlaps(collider))
				{
					var tabName:String = ["projects", "settings", "voicebanks"][i];
					FlxG.cameras.remove(tabCam, true);
					tabCam = Type.createInstance(tabs.get(tabName), [18, 203, this]);
					FlxG.cameras.add(tabCam, false);
					overlay.loadGraphic('_assets/UI-${i + 1}.png');
					changedTab = true;
					break;
				}
			}
			if (!changedTab)
				overlay.loadGraphic('_assets/UI-0.png');
		}
	}
}
