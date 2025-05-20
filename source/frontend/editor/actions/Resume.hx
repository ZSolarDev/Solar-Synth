package frontend.editor.actions;

class Resume implements IAction
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
			FlxG.sound.resume();
			endExecute();
		}
		catch (e)
			throw 'Error stating RESUME action:\n${e.details()}';
	}

	public function update(?data:Dynamic) {}

	public function endExecute()
	{
		complete = true;
	}
}
