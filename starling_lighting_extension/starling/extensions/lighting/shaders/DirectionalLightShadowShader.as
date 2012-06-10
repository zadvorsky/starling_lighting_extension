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
	public class DirectionalLightShadowShader extends StarlingShaderBase
	{
		private const NAME:String = "DirectionalLightShadowShader";
		
		private var _vertexBuffer:VertexBuffer3D;
		private var params:Vector.<Number>;
		
		public function DirectionalLightShadowShader()
		{
			super(NAME);
			
			params = new Vector.<Number>(4);
		}
		
		public function setDependencies(vertexBuffer:VertexBuffer3D, light:DirectionalLight):void
		{
			_vertexBuffer = vertexBuffer;
			
			params[0] = light.directionVector.x;
			params[1] = light.directionVector.y;
		}
				
		override protected function activateHook(context:Context3D):void
		{
			context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 1, params);
			context.setVertexBufferAt(0, _vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
		}
		
		override protected function vertexShaderProgram():String
		{
			//vc1 = [dx, dy, 0, 0]
			var program:String =
			
			"mul vt0.xy, vc1.xy, va0.z \n" + //delta xy * shadow multiplier (0 || 1) = shadow xy
			
			"mul vt0.xy, vt0.xy, vc0.z \n" + //shadow xy * 1000
			"add vt1.xy, va0.xy, vt0.xy \n" + //world xy + shadow xy
			
			"mov vt1.z, vc0.xy.x \n" + //vt1.z = 0
			"mov vt1.w, vc0.xy.y \n" + //vt1.w = 1
			"m44 op, vt1, vc2"; //project to clip space
			
			return program;
		}
		
		override protected function fragmentShaderProgram():String
		{
			var program:String =
			
			"mov oc, fc0";
			
			return program;
		}
	}
}
