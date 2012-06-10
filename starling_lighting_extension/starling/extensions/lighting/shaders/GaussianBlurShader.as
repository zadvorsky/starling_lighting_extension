package starling.extensions.lighting.shaders
{
	import starling.core.Starling;

	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.VertexBuffer3D;
	import flash.display3D.textures.Texture;

	/**
	 * @author Szenia Zadvornykh
	 * 
	 * original shader by Eugene Zatepyakin @ inspirit.ru
	 */
	public class GaussianBlurShader extends StarlingShaderBase
	{
		private const NAME:String = "GaussianBlurShader";
		
		private const GAUSSIAN_FACTORS:Vector.<Number> = new <Number>[0.002216, 0.008764, 0.026995, 0.064759, 0.120985, 0.176033, 0.199471, 0];
		private const QUALITY:int = 6;
		
		private var hParams:Vector.<Number>;
		private var vParams:Vector.<Number>;
		
		private var _textureIn:Texture;
		private var _textureOut:Texture;
		private var textureTemp:Texture;
		private var _vertexBuffer:VertexBuffer3D;
		private var _uvBuffer:VertexBuffer3D;

		/**
		 * @param quality sample size randing from 2 to 6
		 */
		public function GaussianBlurShader(width:int, height:int, blurSize:Number)
		{
			super(NAME);
				
			hParams = new Vector.<Number>(12);
			vParams = new Vector.<Number>(12);

			textureTemp = Starling.context.createTexture(width, height, Context3DTextureFormat.BGRA, true);
					
			hParams[0] = (1 / width) * blurSize * QUALITY;
			hParams[2] = (1 / width) * blurSize;
			vParams[1] = (1 / height) * blurSize * QUALITY;
			vParams[3] = (1 / height) * blurSize;
			
			var gaussianIndex:int = 0;
			var gaussianFactor:Number;
			
			for(var i:int = 4; i < 12; i++)
			{
				gaussianFactor = GAUSSIAN_FACTORS[gaussianIndex];
				
				hParams[i] = gaussianFactor;
				vParams[i] = gaussianFactor;

				gaussianIndex++;
			}
		}

		public function setDependencies(textureIn:Texture, textureOut:Texture, vertexBuffer:VertexBuffer3D, uvBuffer:VertexBuffer3D):void
		{
			_textureIn = textureIn;
			_textureOut = textureOut;
			_vertexBuffer = vertexBuffer;
			_uvBuffer = uvBuffer;
		}

		override protected function activateHook(context:Context3D):void
		{
			context.setRenderToTexture(textureTemp);
			context.clear(0, 0, 0, 1);
			
			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, hParams);
			context.setVertexBufferAt(0, _vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
			context.setVertexBufferAt(1, _uvBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
			context.setTextureAt(0, _textureIn);
		}
		
		public function activateSecondPass(context:Context3D):void
		{
			context.setRenderToTexture(_textureOut);
			context.clear(0, 0, 0, 1);

			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, vParams);
			context.setTextureAt(0, textureTemp);
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
			/**
			 * d = delta x || y
			 * G = gaussian kernel
			 * 
			 * fc0 = [d * G.length, 0, d, 0]
			 * fc1 = [G0, G1, G2, G3]
			 * fc2 = [G4, G5, G6, 0]
			 */

			var gaussianKernelRegs:Vector.<String> = new Vector.<String>(13);
			
			gaussianKernelRegs[0] = "fc1.x";
			gaussianKernelRegs[1] = "fc1.y";
			gaussianKernelRegs[2] = "fc1.z";
			gaussianKernelRegs[3] = "fc1.w";
			gaussianKernelRegs[4] = "fc2.x";
			gaussianKernelRegs[5] = "fc2.y";

			gaussianKernelRegs[6] = "fc2.z";

			gaussianKernelRegs[7] = "fc2.y";
			gaussianKernelRegs[8] = "fc2.x";
			gaussianKernelRegs[9] = "fc1.w";
			gaussianKernelRegs[10] = "fc1.z";
			gaussianKernelRegs[11] = "fc1.y";
			gaussianKernelRegs[12] = "fc1.x";

			var program:String = 
			
			"mov ft0, v0 \n" + 
			"sub ft0.xy, ft0.xy, fc0.xy \n" + 
			"tex ft1, ft0, fs0 <2d, linear, mipnearest> \n" + 
			"mul ft1.xyz, ft1.xyz, " + gaussianKernelRegs[0] + " \n" + 
			"add ft0.xy, ft0.xy, fc0.zw \n";

			for(var i:int = 1; i < gaussianKernelRegs.length - 1; ++i)
			{
				program += 
				
				"tex ft2, ft0, fs0 <2d, linear, mipnearest> \n" + 
				"mul ft2.xyz, ft2.xyz, " + gaussianKernelRegs[i] + " \n" + 
				"add ft1, ft1, ft2 \n" + 
				"add ft0.xy, ft0.xy, fc0.zw \n";
			}

			program += 
			
			"tex ft2, ft0, fs0 <2d, linear, mipnearest> \n" + 
			"mul ft2.xyz, ft2.xyz, " + gaussianKernelRegs[gaussianKernelRegs.length - 1] + " \n" + 
			"add oc, ft1, ft2 \n";

			return program;
		}
	}
}
