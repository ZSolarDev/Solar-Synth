package backend.audio.areo;

import backend.data.Note;

class BreathRegion
{
	public var startTime:Int;
	public var endTime:Int;
	public var notes:Array<Note>;

	public function new(start:Int)
	{
		startTime = start;
		endTime = start;
		notes = [];
	}
}
