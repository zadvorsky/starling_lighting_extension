package starling.extensions.lighting.shaders
{

	/**
	 * @author Szenia Zadvornykh
	 */
	public class LightLayerPointLightShader extends StarlingShaderBase
	{
		private const NAME:String = "LightLayerPointLightShader";
		
		public function LightLayerPointLightShader()
		{
			super(NAME);
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
			var program:String =
			
			"mul ft0.xy, fc1.zw, v0.xy \n" +
			"sub ft1.xy, ft0.xy, fc1.xy \n" +
			"mov ft1.z, fc2.x \n" +
			"dp3 ft1.x, ft1.xyz, ft1.xyz \n" +
			"sqt ft1.xyz, ft1.xyz \n" +
			"div ft1.x, ft1.x, fc2.w \n" +
			"sat ft1.x, ft1.x \n" +
			"sub ft1.x, fc2.y, ft1.x \n" +
			"mul ft1.xyz, ft1.x, fc3.xyz \n" +
			"mov ft1.w, fc3.w \n" +
			"mov oc, ft1 \n";
			
			return program;
		}
	}
}