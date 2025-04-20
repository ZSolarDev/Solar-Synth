package frontend.startmenu;

import backend.utils.SSProjectUtil;
import haxe.Json;
import openfl.events.Event;
import openfl.net.FileFilter;
import openfl.net.FileReference;
import sys.io.File;

class Project extends FlxSpriteGroup
{
	public var txt:FlxText;
	public var tab:Tab;

	override public function new(tab:Tab, name:String)
	{
		super();
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
				inline function loadSongEditor(path:String)
					FlxG.switchState(() -> new frontend.editor.SongEditor(SSProjectUtil.typedefToProject(cast Json.parse(File.getContent(path)))));
				switch (txt.text)
				{
					case 'New project...':
						FlxG.state.openSubState(new NewProject());
					case 'Open project...':
						var file = new FileReference();
						file.addEventListener(Event.SELECT, (_) ->
						{
							var path:String = '';
							@:privateAccess
							if (file.__path != null)
								path = file.__path;
							if (path != '')
								loadSongEditor(path);
						});
						file.browse([new FileFilter('Solar Synth Projects(*.ssp)', '*.ssp')]);
					default:
						loadSongEditor(txt.text);
				}
			}
		}
		catch (e)
			trace(e.details);
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
