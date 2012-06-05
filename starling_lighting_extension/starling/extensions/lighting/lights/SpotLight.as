package starling.extensions.lighting.lights
{
	import starling.utils.rad2deg;
	import starling.extensions.lighting.core.LightBase;
	import starling.extensions.lighting.util.LightUtils;
	import starling.utils.deg2rad;

	import flash.geom.Vector3D;

	/**
	 * @author Szenia
	 */
	public class SpotLight extends LightBase
	{
		private var _x:int;
		private var _y:int;
		private var _radius:int;
		private var _direction:int;
		private var _directionVector:Vector3D;
		private var _coneAngle:int;
		private var _focus:int;
		
		/**
		 * A light that illuminates a cone shaped segment of the scene.
		 * Usefull for flashlights and, well, spotlights.
		 * 
		 * @param x x position of the light in world cooridinates
		 * @param y y position of the light in world cooridinates
		 * @param radius radius of the light in world space
		 * @param direction direction the spotlight is facing, in degrees
		 * @param coneAngle the angle of illumination
		 * @param focus increase to brighten the light along the cone center
		 * @param color RGB color of the light. No alpha channel.
		 * @param brightness brightness modifier. Values > 1 dim the light, values < 1 brighten it.
		 */
		public function SpotLight(x:int, y:int, radius:int, direction:int, coneAngle:int, focus:int, color:uint, brightness:Number = 1)
		{
			super(color, brightness);
			
			_x = x;
			_y = y;
			_radius = radius;
			_coneAngle = coneAngle;
			_focus = focus;
			
			_directionVector = new Vector3D();
			this.direction = direction;
		}

		public function get x():int
		{
			return _x;
		}

		public function set x(x:int):void
		{
			_x = x;
		}

		public function get y():int
		{
			return _y;
		}

		public function set y(y:int):void
		{
			_y = y;
		}

		public function get radius():int
		{
			return _radius;
		}

		public function set radius(radius:int):void
		{
			_radius = radius;
		}

		public function get direction():int
		{
			return _direction;
		}

		public function set direction(direction:int):void
		{
			_direction = direction;
			directionVector = LightUtils.vectorFromDegrees(direction, _directionVector);
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
		
		public function get coneAngle():int
		{
			return _coneAngle;
		}
		
		public function set coneAngle(angle:int):void
		{
			_coneAngle = angle;
		}
		
		/**
		 * returns the cosine of half of the cone angle to be used in the shader
		 */
		public function halfConeAngleCos():Number
		{
			return Math.cos(deg2rad(_coneAngle / 2));
		}
		
		public function get focus():int 
		{
			return _focus;
		}
		
		public function set focus(value:int):void 
		{
			_focus = value;
		}
	}
}
