package starling.extentions.lighting.shaders
{
	import starling.core.Starling;
	import starling.errors.AbstractMethodError;

	import com.adobe.utils.AGALMiniAssembler;

	import flash.display3D.Context3DProgramType;
	import flash.display3D.Program3D;
	import flash.utils.ByteArray;
	
	/**
	 * @author Szenia Zadvornykh
	 */
	public class StarlingShaderBase
	{
		protected var _name:String;
		
		/**
		 * abstract baseclass wrapping shader code and registration with Starling
		 */
		public function StarlingShaderBase(name:String)
		{
			_name = name;
			
			register();
		}
		
		private function register():void
		{
			var target:Starling = Starling.current;
			
			if(target.hasProgram(_name)) return;

			target.registerProgram(_name, assembleVertexShader(), assembleFragmentShader());
		}

		private function assembleVertexShader():ByteArray
		{
			var vertexProgramAssembler:AGALMiniAssembler = new AGALMiniAssembler();
			vertexProgramAssembler.assemble(Context3DProgramType.VERTEX, vertexShaderProgram());

			return vertexProgramAssembler.agalcode;
		}

		protected function vertexShaderProgram():String
		{
			throw new AbstractMethodError();
		}

		private function assembleFragmentShader():ByteArray
		{
			var fragmentProgramAssembler:AGALMiniAssembler = new AGALMiniAssembler();
			fragmentProgramAssembler.assemble(Context3DProgramType.FRAGMENT, fragmentShaderProgram());

			return fragmentProgramAssembler.agalcode;
		}

		protected function fragmentShaderProgram():String
		{
			throw new AbstractMethodError();
		}
		
		final public function get program():Program3D
		{
			return Starling.current.getProgram(name);
		}
		
		final public function get name():String
		{
			return _name;
		}
	}
}
