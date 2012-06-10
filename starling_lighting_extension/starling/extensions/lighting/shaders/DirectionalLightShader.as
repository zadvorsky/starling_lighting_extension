package starling.extensions.lighting.shaders
{
	import starling.extensions.lighting.lights.DirectionalLight;

	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.VertexBuffer3D;

	/**
	 * @author Szenia
	 */
	public class DirectionalLightShader extends StarlingShaderBase
	{
		private const NAME:String = "DirectionalLightShader";
		
		private var params:Vector.<Number>;
		private var _vertexBuffer:VertexBuffer3D;
		
		public function DirectionalLightShader()
		{
			super(NAME);

			params = new Vector.<Number>(4);

			params[3] = 1;
		}
		
		public function setDependencies(vertexBuffer:VertexBuffer3D):void
		{
			_vertexBuffer = vertexBuffer;
			
		}
		
		public function set light(light:DirectionalLight):void
		{
			params[0] = light.red;
			params[1] = light.green;
			params[2] = light.blue;
		}
				
		override protected function activateHook(context:Context3D):void
		{
			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1, params);
			context.setVertexBufferAt(0, _vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
		}
		
		override protected function vertexShaderProgram():String
		{
			var program:String =
			
			"mov op, va0 \n" +
			"";
			
			return program;
		}
		
		override protected function fragmentShaderProgram():String
		{
			//fc1 = [red, green, blue, 1]
			var program:String =
			
			"mov oc, fc1 \n" +
			"";
			
			return program;
		}
	}
}
