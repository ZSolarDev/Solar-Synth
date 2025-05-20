package frontend.editor.actions;

class Stop implements IAction
{
	public var complete:Bool = false;
	public var res:Dynamic;
	public var editor:SongEditor;
	public var running:Bool;

	public function new() {}

	public function startExecute(?data:Dynamic)
	{
		try
		{
			editor = SongEditor.instance;
			// basically FlxG.sound.music.stop();
			for (sound in FlxG.sound.list.members)
				if (sound != null && sound.exists && sound.active)
					sound.stop();
			endExecute();
		}
		catch (e)
			throw 'Error stating STOP action:\n${e.details()}';
	}

	public function update(?data:Dynamic) {}

	public function endExecute()
	{
		complete = true;
	}
}
