package frontend.startmenu;

class VoicebanksTab extends Tab
{
	override public function create()
	{
		var project:FlxSprite = new FlxSprite(0, 0).makeGraphic(30, 60, FlxColor.MAGENTA);
		items.push(project);
		var project1:FlxSprite = new FlxSprite(0, 0).makeGraphic(40, 70, FlxColor.PINK);
		items.push(project1);
		var project2:FlxSprite = new FlxSprite(0, 0).makeGraphic(50, 10, FlxColor.BROWN);
		items.push(project2);
		super.create();
	}
}
