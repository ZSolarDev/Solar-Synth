package frontend.startmenu;

class Project extends FlxSpriteGroup
{
	public var bg:FlxSprite;
	public var txt:FlxText;
	public var tab:Tab;

	override public function new(tab:Tab, name:String)
	{
		super();
		bg = new FlxSprite(0, 0).makeGraphic(tab.width, 30, 0xFFFFFF);
		add(bg);

		txt = new FlxText(2, 5, 0, name, 20);
		txt.font = '_assets/ui.otf';
		add(txt);

		this.tab = tab;
	}

	override public function update(elapsed:Float)
	{
		try
		{
			if (FlxG.mouse.overlaps(this, tab) && FlxG.mouse.justPressed)
			{
				switch (txt.text)
				{
					case 'New project...':
						FlxG.switchState(() -> new SongEditor({
							name: 'Untitled',
							voicebank: 'Kasane Teto Lite',
							timeSignatureNumerator: 4,
							timeSignatureDenominator: 4,
							tracks: [
								{
									name: 'Track 0',
									sections: [
										{
											time: 0,
											name: 'Section 0',
											notes: [],
											bpm: 120
										}
									],
									muted: false,
									volume: 1
								}
							],
							settings: {
								test: false
							}
						}));
					case 'Open project...':
						FlxG.switchState(() -> new SongEditor({
							name: 'Untitled',
							voicebank: 'Kasane Teto Lite',
							timeSignatureNumerator: 4,
							timeSignatureDenominator: 4,
							tracks: [
								{
									name: 'Track 0',
									sections: [
										{
											time: 0,
											name: 'Section 0',
											notes: [],
											bpm: 120
										}
									],
									muted: false,
									volume: 1
								}
							],
							settings: {
								test: false
							}
						}));
					default:
				}
			}
		}
		catch (e) {}
	}
}

class ProjectsTab extends Tab
{
	override public function create()
	{
		itemPadding = 0;
		items.push(new Project(this, 'New project...'));
		items.push(new Project(this, 'Open project...'));
		super.create();
	}
}
