package starling.extensions.lighting.shaders
{
	import starling.extensions.lighting.lights.SpotLight;

	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.VertexBuffer3D;

	/**
	 * @author Szenia
	 */
	public class SpotLightShader extends StarlingShaderBase
	{
		private const NAME:String = "SpotLightShader";
		
		private var params:Vector.<Number>;
		private var _vertexBuffer:VertexBuffer3D;
		private var _uvBuffer:VertexBuffer3D;
		
		public function SpotLightShader(width:int, height:int)
		{
			super(NAME);
			
			params = new Vector.<Number>(16);
			
			params[2] = width;
			params[3] = height;
			params[4] = 0;
			params[5] = 1;
			params[11] = 1;
			params[14] = 0;
		}
		
		public function setDependencies(vertexBuffer:VertexBuffer3D, uvBuffer:VertexBuffer3D):void
		{
			_vertexBuffer = vertexBuffer;
			_uvBuffer = uvBuffer;
		}
		
		public function set light(light:SpotLight):void
		{
			params[0] = light.x;
			params[1] = light.y;
			params[6] = light.focus;
			params[7] = light.radius;
			params[8] = light.red;
			params[9] = light.green;
			params[10] = light.blue;
			params[12] = light.directionVector.x;
			params[13] = light.directionVector.y;
			params[15] = light.halfConeAngleCos();
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
			//fc2 = [0, 1, focus, radius]
			//fc3 = [red, green, blue, 1(alpha)] = color
			//fc4 = [direction.x, direction.y, 0, cos(angle / 2)]
			
			var program:String =
			
			//get vector from fragment.xy to light.xy
			"mul ft0.xy, fc1.zw, v0.xy \n" +
			"sub ft1.xy, ft0.xy, fc1.xy \n" +
			"mov ft1.z, fc2.x \n" +
			
			//spot attenuation
			"nrm ft2.xyz, ft1.xyz \n" +
			"dp3 ft2.x, ft2.xyz, fc4.xyz \n" +
			"sge ft2.y, ft2.x, fc4.w \n" +
			"mul ft2.x, ft2.x, ft2.y \n" +
			"pow ft2.x, ft2.x, fc2.z \n" +
			
			//distance attenuation
			"dp3 ft1.x, ft1.xyz, ft1.xyz \n" +	
			"sqt ft1.xyz, ft1.xyz \n" +	
			"div ft1.x, ft1.x, fc2.w \n" +		
			"sat ft1.x, ft1.x \n" +
			"sub ft1.x, fc2.y, ft1.x \n" +
			
			//oc = distance attenuation * spotAttenuation * color
			"mul ft2.x, ft2.x, ft1.x \n" +			
			"mul oc, ft2.x, fc3.xyz";
			
			return program;
		}
	}
}
