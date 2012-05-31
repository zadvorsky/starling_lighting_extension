package starling.extensions.lighting.core
{
	import flash.geom.Point;
	/**
	 * ...
	 * @author Ryan Speets
	 */
	public class Edge 
	{
		private var _start:Point;
		private var _end:Point;
		
		/**
		 * simple class to hold the start and end points of an edge used for shadow casting
		 */
		public function Edge(start:Point, end:Point)
		{
			_start = start;
			_end = end;
		}

		public function get start():Point
		{
			return _start;
		}

		public function set start(start:Point):void
		{
			_start = start;
		}

		public function get end():Point
		{
			return _end;
		}

		public function set end(end:Point):void
		{
			_end = end;
		}
		
		public function toString():String
		{
			return "start (" + _start.x + ", " + _start.y + ") end (" + _end.x + ", " + _end.y + ")";
		}
	}
}