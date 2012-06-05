package starling.extensions.lighting.shaders
{
	/**
	 * @author Szenia Zadvornykh
	 */
	public class LightMapShader extends StarlingShaderBase
	{
		private const NAME:String = "LightMapShader";
		
		public function LightMapShader()
		{
			super(NAME);
		}
		
		override protected function vertexShaderProgram():String
		{
			var program:String =
			
			"mov op, va0 \n" +
			"mul v0, va1, vc0 \n";
			
			return program;
		}
		
		override protected function fragmentShaderProgram():String
		{
			var program:String = 
			
			"tex ft0, v0.xy, fs0<2d, nearest, mipnone> \n" +
			"add oc, ft0, fc0";

			return program;
		}
	}
}
