package frontend.startmenu;

class SettingsTab extends Tab
{
	override public function create()
	{
		var project:FlxSprite = new FlxSprite(0, 0).makeGraphic(60, 30, FlxColor.GREEN);
		items.push(project);
		var project1:FlxSprite = new FlxSprite(0, 0).makeGraphic(70, 40, FlxColor.LIME);
		items.push(project1);
		var project2:FlxSprite = new FlxSprite(0, 0).makeGraphic(10, 50, FlxColor.CYAN);
		items.push(project2);
		super.create();
	}
}
