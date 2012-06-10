package starling.extensions.lighting.shaders
{

	import starling.extensions.lighting.lights.PointLight;

	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.VertexBuffer3D;
	/**
	 * @author Szenia Zadvornykh
	 * 
	 * original shader by Ryan Speets @ ryanspeets.com
	 */
	public class PointLightShader extends StarlingShaderBase
	{
		private const NAME:String = "PointLightShader";
		
		private var params:Vector.<Number>;
		private var _vertexBuffer:VertexBuffer3D;
		private var _uvBuffer:VertexBuffer3D;
		
		public function PointLightShader(width:int, height:int)
		{
			super(NAME);
			
			params = new Vector.<Number>(12);
			
			params[2] = width;
			params[3] = height;
			params[4] = 0;
			params[5] = 1;
			params[6] = 0;
			params[11] = 1;
		}
		
		public function setDependencies(vertexBuffer:VertexBuffer3D, uvBuffer:VertexBuffer3D):void
		{
			_vertexBuffer = vertexBuffer;
			_uvBuffer = uvBuffer;
		}
		
		public function set light(light:PointLight):void
		{
			params[0] = light.x;
			params[1] = light.y;
			params[7] = light.radius;
			params[8] = light.red;
			params[9] = light.green;
			params[10] = light.blue;
		}
				
		override protected function activateHook(context:Context3D):void
		{
			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1, params);
			context.setVertexBufferAt(0, _vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
			context.setVertexBufferAt(1, _uvBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
		}
		
		override protected function vertexShaderProgram():String
		{
			var program:String =
			
			"mov op, va0 \n" +
			"mov v0, va1 \n";
			
			return program;
		}
		
		override protected function fragmentShaderProgram():String
		{
			//fc1 = [light.x, light.y, width, height]
			//fc2 = [0, 1, 0, radius]
			//fc3 = [red, green, blue, 1(alpha)] = color
			
			var program:String =
			
			//get fragment position in xy space
			"mul ft0.xy, fc1.zw, v0.xy \n" +
			//get vector from fragment position to light center
			"sub ft1.xy, ft0.xy, fc1.xy \n" +
			//set z to 0
			"mov ft1.z, fc2.x \n" +
			//vector to euclidean distance
			"dp3 ft1.x, ft1.xyz, ft1.xyz \n" +	
			"sqt ft1.xyz, ft1.xyz \n" +	
			//if (distance > radius) return 1, else keep
			"div ft1.x, ft1.x, fc2.w \n" +		
			"sat ft1.x, ft1.x \n" +
			//get brightness by subtracting value from 1
			"sub ft1.x, fc2.y, ft1.x \n" +
			//multiply light color by fragment brightness		
			"mul ft1.xyz, ft1.x, fc3.xyz \n" +
			//alpha = 1
			"mov ft1.w, fc3.w \n" +
			"mov oc, ft1 \n";
			
			return program;
		}
	}
}