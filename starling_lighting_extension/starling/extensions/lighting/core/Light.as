package starling.extentions.lighting.core
{
	import starling.utils.Color;
	/**
	 * @author Szenia
	 */
	public class Light
	{
		private var _x:int;
		private var _y:int;
		private var _radius:int;
		private var _brightness:Number;
		private var _r:Number;
		private var _g:Number;
		private var _b:Number;
		
		/**
		 * simple class that holds values needed for lighting. This is not a display object.
		 * 
		 * @param x x position of the light in world cooridinates
		 * @param y y position of the light in world cooridinates
		 * @param radius radius of the light in world space
		 * @param brightness brightness modifier. Values > 1 dim the light, values < 1 brighten it.
		 * @param color RGB color of the light. No alpha channel.
		 */
		public function Light(x:int, y:int, radius:int, color:uint, brightness:Number = 1)
		{
			_x = x;
			_y = y;
			_radius = radius;
			_brightness = brightness;
			
			setColor(color);			
		}

		public function setColor(color:uint):void
		{
			_r = Color.getRed(color) / 255;
			_g = Color.getGreen(color) / 255;
			_b = Color.getBlue(color) / 255;
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

		public function get red():Number
		{
			return _r * _brightness;
		}

		public function get green():Number
		{
			return _g * _brightness;
		}

		public function get blue():Number
		{
			return _b * _brightness;
		}

		public function get brightness():Number
		{
			return _brightness;
		}

		public function set brightness(brightness:Number):void
		{
			_brightness = brightness;
		}
	}
}
