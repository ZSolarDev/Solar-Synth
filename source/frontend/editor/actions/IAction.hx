package frontend.editor.actions;

interface IAction
{
	public var complete:Bool;
	public var running:Bool;
	public var res:Dynamic;
	public var editor:SongEditor;
	public function startExecute(?data:Dynamic):Void;
	public function update(?data:Dynamic):Void;
	public function endExecute():Void;
}
