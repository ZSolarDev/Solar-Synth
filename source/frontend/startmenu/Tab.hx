package frontend.startmenu;

import backend.utils.SSMath;
import flixel.group.FlxGroup;
import openfl.events.MouseEvent;

class Tab extends FlxCamera
{
	public var bg:FlxSprite;
	public var items:Array<FlxObject> = [];
	public var itemPadding:Float = 5;
	public var parent:FlxGroup;
	public var maxTabScroll:Float;
	public var ogY:Float;

	override public function new(x:Float, y:Float, parent:FlxGroup)
	{
		super(x, y, 363, 290);
		this.parent = parent;
		bgColor.alpha = 0;
		bg = new FlxSprite(0, 0, '').makeGraphic(400, 512, 0xFF2E2E2E);
		bg.camera = this;
		parent.add(bg);
		create();
	}

	function create()
	{
		postCreate();
	}

	function postCreate()
	{
		var currentY:Float = 0;
		for (itemID in 0...items.length)
		{
			var item = items[itemID];
			item.y = currentY;
			item.x = x;
			item.camera = this;
			parent.add(item);

			currentY += item.height + itemPadding;
		}
		FlxG.stage.addEventListener(MouseEvent.MOUSE_WHEEL, scrollTab);
		ogY = items[0].y;
	}

	function scrollTab(e:MouseEvent)
	{
		if (items[items.length - 1].y + e.delta * 15 > ogY && items[0].y + e.delta * 15 < items[0].height / 4)
		{
			for (item in items)
				item.y += e.delta * 15;
		}
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
