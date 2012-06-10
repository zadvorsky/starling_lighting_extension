package starling.extensions.lighting.shaders
{
	import starling.utils.Color;

	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.VertexBuffer3D;
	import flash.display3D.textures.Texture;
	/**
	 * @author Szenia Zadvornykh
	 */
	public class LightMapShader extends StarlingShaderBase
	{
		private const NAME:String = "LightMapShader";

		private var vertexParams:Vector.<Number>;

		private var _texture:Texture;
		private var _vertexBuffer:VertexBuffer3D;
		private var _uvBuffer:VertexBuffer3D;
		private var _ambientColor:Vector.<Number> = new <Number>[0, 0, 0, 0];
		
		public function LightMapShader(scaleW:Number, scaleH:Number)
		{
			super(NAME);

			vertexParams = new <Number>[scaleW, scaleH, 0, 0];
			_ambientColor = new Vector.<Number>(4);
		}
		
		public function setDependencies(texture:Texture, vertexBuffer:VertexBuffer3D, uvBuffer:VertexBuffer3D):void
		{
			_texture = texture;
			_vertexBuffer = vertexBuffer;
			_uvBuffer = uvBuffer;
			
		}
		
		public function setAmbientColor(color:uint, intensity:Number):void
		{
			var r:Number = Color.getRed(color) / 255;
			var g:Number = Color.getGreen(color) / 255;
			var b:Number = Color.getBlue(color) / 255;
			
			_ambientColor[0] = r * intensity;
			_ambientColor[1] = g * intensity;
			_ambientColor[2] = b * intensity;
			_ambientColor[3] = 0;
		}
		
		override protected function activateHook(context:Context3D):void
		{
			context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0, vertexParams);
			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, _ambientColor);
			context.setVertexBufferAt(0, _vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
			context.setVertexBufferAt(1, _uvBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
			context.setTextureAt(0, _texture);
		}
		
		override protected function vertexShaderProgram():String
		{
			var program:String =
			
			"mov op, va0 \n" +
			"mul v0, va1, vc0.xy \n";
			
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
