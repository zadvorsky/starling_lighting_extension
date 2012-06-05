package starling.extensions.lighting.shaders
{
	import starling.extensions.lighting.shaders.StarlingShaderBase;

	/**
	 * @author Szenia
	 */
	public class DirectionalLightShadowShader extends StarlingShaderBase
	{
		private const NAME:String = "DirectionalLightShadowShader";
		
		public function DirectionalLightShadowShader()
		{
			super(NAME);
		}
		
		override protected function vertexShaderProgram():String
		{
			//vc1 = [dx, dy, 0, 0]
			var program:String =
			
//			"sub vt0.xy, va0.xy, vc1.xy \n" + //world xy - light xy = delta xy
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
