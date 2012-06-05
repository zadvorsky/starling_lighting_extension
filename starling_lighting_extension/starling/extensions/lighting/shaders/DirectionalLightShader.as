package starling.extensions.lighting.shaders
{
	import starling.extensions.lighting.shaders.StarlingShaderBase;

	/**
	 * @author Szenia
	 */
	public class DirectionalLightShader extends StarlingShaderBase
	{
		private const NAME:String = "DirectionalLightShader";
		
		public function DirectionalLightShader()
		{
			super(NAME);
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
