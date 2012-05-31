package starling.extentions.lighting.core
{
	import flash.geom.Vector3D;
	/**
	 * ...
	 * @author Ryan Speets
	 */
	public class Edge 
	{
		private var _start:Vector3D;
		private var _end:Vector3D;
		
		/**
		 * simple class to hold the start and end points of an edge used for shadow casting
		 */
		public function Edge(start:Vector3D, end:Vector3D)
		{
			_start = start;
			_end = end;
		}

		public function get start():Vector3D
		{
			return _start;
		}

		public function set start(start:Vector3D):void
		{
			_start = start;
		}

		public function get end():Vector3D
		{
			return _end;
		}

		public function set end(end:Vector3D):void
		{
			_end = end;
		}
		
		public function toString():String
		{
			return "start (" + _start.x + ", " + _start.y + ") end (" + _end.x + ", " + _end.y + ")";
		}
	}
}