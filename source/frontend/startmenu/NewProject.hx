package frontend.startmenu;

class NewProject extends FlxSubState
{
	public var bg:FlxSprite;
	public var box:FlxSprite;
	public var typeProjectNameHere:FlxText;
	public var songName:FlxInputText;
	public var createButton:FlxText;
	public var cam:FlxCamera;

	override public function create()
	{
		super.create();
		cam = new FlxCamera(0, 0, FlxG.width, FlxG.height);
		cam.bgColor.alpha = 0;
		FlxG.cameras.add(cam);
		bg = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		bg.alpha = 0.5;
		bg.camera = cam;
		add(bg);
		box = new FlxSprite(20, FlxG.height / 2 - (FlxG.height / 4) / 2).makeGraphic(FlxG.width - 40, cast FlxG.height / 4, 0xFF2E2E2E);
		box.camera = cam;
		add(box);
		typeProjectNameHere = new FlxText(box.x + 10, box.y + 10, box.x + box.width - 30, 'Type Project Name Here', 15);
		typeProjectNameHere.alignment = CENTER;
		typeProjectNameHere.font = '_assets/ui.otf';
		typeProjectNameHere.camera = cam;
		add(typeProjectNameHere);
		songName = new FlxInputText(typeProjectNameHere.x, typeProjectNameHere.y + typeProjectNameHere.height + 10, box.x + box.width - 40, 'New Project', 15);
		songName.alignment = CENTER;
		songName.font = '_assets/ui.otf';
		songName.camera = cam;
		add(songName);
		createButton = new FlxText(typeProjectNameHere.x, box.y + box.height - 30, box.x + box.width - 30, 'Create', 20);
		createButton.alignment = CENTER;
		createButton.font = '_assets/ui.otf';
		createButton.camera = cam;
		add(createButton);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if (FlxG.mouse.overlaps(createButton))
		{
			createButton.color = 0xFFC0C0C0;
			if (FlxG.mouse.justPressed)
			{
				FlxG.cameras.remove(cam);
				cam.destroy();
				FlxG.switchState(() -> new frontend.editor.SongEditor({
					name: songName.text,
					voicebank: 'Kasane Teto Lite',
					timeSignatureNumerator: 4,
					timeSignatureDenominator: 4,
					tracks: [],
					settings: {
						test: false
					}
				}));
			}
		}
		else
			createButton.color = 0xFFFFFFFF;
		if (FlxG.keys.justPressed.ESCAPE)
		{
			FlxG.cameras.remove(cam);
			cam.destroy();
			close();
		}
	}
}
