package frontend.editor.actions;

class Pause implements IAction
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
			FlxG.sound.pause();
			endExecute();
		}
		catch (e)
			throw 'Error stating PAUSE action:\n${e.details()}';
	}

	public function update(?data:Dynamic) {}

	public function endExecute()
	{
		complete = true;
	}
}
