package starling.extensions.lighting.lights
{
	import starling.extensions.lighting.core.LightBase;
	import starling.extensions.lighting.util.LightUtils;
	import starling.utils.rad2deg;

	import flash.geom.Vector3D;

	/**
	 * @author Szenia Zadvornykh
	 */
	public class DirectionalLight extends LightBase
	{
		private var _direction:int;
		private var _directionVector:Vector3D;

		/**
		 * A very distant light that illuminates the entire scene, casting shadows in the same direction (like the sun)
		 * 
		 * @param direction vector representing the direction of the light
		 * @param color RGB color of the light. No alpha channel.
		 * @param brightness brightness modifier. Values > 1 dim the light, values < 1 brighten it.
		 */
		public function DirectionalLight(direction:int, color:uint, brightness:Number = 1)
		{
			super(color, brightness);
			
			_directionVector = new Vector3D();
			this.direction = direction;
		}

		public function get direction():int
		{
			return _direction;
		}

		public function set direction(direction:int):void
		{
			_direction = direction;
			LightUtils.vectorFromDegrees(direction, _directionVector);
		}

		public function set directionRadians(radians:Number):void
		{
			_direction = rad2deg(radians);
			LightUtils.vectorFromRadians(radians, _directionVector);
		}
		
		public function set directionVector(vector:Vector3D):void
		{
			_directionVector = vector;
		}
		
		public function get directionVector():Vector3D
		{
			return _directionVector;
		}
	}
}
