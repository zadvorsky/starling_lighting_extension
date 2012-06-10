package starling.extensions.lighting.core
{
	import starling.extensions.lighting.shaders.GaussianBlurShader;
	import starling.extensions.lighting.shaders.SpotLightShader;
	import starling.extensions.lighting.lights.SpotLight;
	import starling.extensions.lighting.shaders.DirectionalLightShadowShader;
	import starling.extensions.lighting.lights.DirectionalLight;
	import starling.extensions.lighting.shaders.DirectionalLightShader;
	import com.adobe.utils.PerspectiveMatrix3D;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DClearMask;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DStencilAction;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.Context3DTriangleFace;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;
	import flash.display3D.textures.Texture;
	import flash.geom.Rectangle;
	import starling.core.RenderSupport;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.extensions.lighting.lights.PointLight;
	import starling.extensions.lighting.shaders.LightMapShader;
	import starling.extensions.lighting.shaders.PointLightShader;
	import starling.extensions.lighting.shaders.PositionalLightShadowShader;
	import starling.utils.Color;

	/**
	 * @author Szenia Zadvornykh
	 * 
	 * original setup by Ryan Speets @ ryanspeets.com
	 */
	public class LightLayer extends DisplayObject
	{
		private var lights:Vector.<LightBase>;
		
		private var pointLightShader:PointLightShader;
		private var pointLightShadowShader:PositionalLightShadowShader;
		private var directionalLightShader:DirectionalLightShader;
		private var directionalLightShadowShader:DirectionalLightShadowShader;
		private var spotLightShader:SpotLightShader;
		private var sceneShader:LightMapShader;
		private var blurShader:GaussianBlurShader;
		
		private var sceneVertexBuffer:VertexBuffer3D;
		private var sceneUVBuffer:VertexBuffer3D;
		private var sceneIndexBuffer:IndexBuffer3D;

		private var lightMapIn:Texture;
		private var lightMapOut:Texture;
		
		private var _width:int;
		private var _height:int;
		private var legalWidth:uint;
		private var legalHeight:uint;
		private var _ambientColor:Vector.<Number>;
		private var _shadowSoftness:Number;
		
		private var projectionMatrix:PerspectiveMatrix3D;
		
		private var geometry:Vector.<ShadowGeometry>;
		private var geometryVertexBuffer:VertexBuffer3D;
		private var geometryIndexBuffer:IndexBuffer3D;
		private var geometryVertexCount:uint;
		
		/**
		 * v0.1
		 * 
		 * Creates a new LightLayer display object. This must be added on top of any shadow casting objects.
		 * 
		 * Light sources can be added with @see addLight
		 * Shadow-casting geometry can be added with @see addGeometryForDisplayObject
		 * 
		 * Current version can create shadow-casting geometry from Image, Quad and RegularPolygon (included in this package)
		 * Shadow-casting geometry is created from VertexData (bounding box), not from pixels. 
		 * 
		 * @param width width of the display
		 * @param height height of the display
		 * @param ambientColor color of the ambient light, default black. This does not cast shadows.
		 * @param ambientColorIntencity intencity of the ambient light. Values range from 0 to 1
		 * @param shadowSoftness control how soft the shadow eges are. Minimum of 1
		 */
		public function LightLayer(width:int, height:int, ambientColor:uint = 0x000000, ambientColorIntensity:Number = 1, shadowSoftness:Number = 2)
		{
			_width = width;
			_height = height;
			_shadowSoftness = shadowSoftness;
						
			lights = new <LightBase>[];
			geometry = new <ShadowGeometry>[];
			_ambientColor = new <Number>[];
			
			createScene();
			createShaders();
			
			setAmbientLightColor(ambientColor, ambientColorIntensity);
			
			touchable = false;
		}

		private function createScene():void
		{
			var context:Context3D = Starling.context;

			sceneVertexBuffer = context.createVertexBuffer(4, 2);
			sceneVertexBuffer.uploadFromVector(Vector.<Number>([-1,-1, 1,-1, 1,1, -1,1]), 0, 4);
			sceneUVBuffer = context.createVertexBuffer(4, 2);
			sceneUVBuffer.uploadFromVector(Vector.<Number>([0,1, 1,1, 1,0, 0,0]), 0, 4);
			sceneIndexBuffer = context.createIndexBuffer(6);
			sceneIndexBuffer.uploadFromVector(Vector.<uint>([0, 2, 1, 0, 3, 2]), 0, 6);
		
			legalWidth = nextPowerOfTwo(_width);
			legalHeight = nextPowerOfTwo(_height);
			
			lightMapIn = context.createTexture(legalWidth, legalHeight, Context3DTextureFormat.BGRA, true);
			lightMapOut = context.createTexture(legalWidth, legalHeight, Context3DTextureFormat.BGRA, true);
			
			projectionMatrix = new PerspectiveMatrix3D();
			projectionMatrix.orthoOffCenterLH(0, legalWidth, -legalHeight, 0, -1, 1);
		}
		
		private function createShaders():void
		{
			pointLightShader = new PointLightShader(legalWidth, legalHeight);
			pointLightShader.setDependencies(sceneVertexBuffer, sceneUVBuffer);

			spotLightShader = new SpotLightShader(legalWidth, legalHeight);
			spotLightShader.setDependencies(sceneVertexBuffer, sceneUVBuffer);

			directionalLightShader = new DirectionalLightShader();
			directionalLightShader.setDependencies(sceneVertexBuffer);

			pointLightShadowShader = new PositionalLightShadowShader();
			
			directionalLightShadowShader = new DirectionalLightShadowShader();
			
			blurShader = new GaussianBlurShader(legalWidth, legalHeight, _shadowSoftness >= 1 ? _shadowSoftness : 1);
			blurShader.setDependencies(lightMapIn, lightMapOut, sceneVertexBuffer, sceneUVBuffer);

			sceneShader = new LightMapShader(_width / legalWidth, _height / legalHeight);
			sceneShader.setDependencies(lightMapOut, sceneVertexBuffer, sceneUVBuffer);
		}
		
		/**
		 * creates shadow casting edges for a display object.
		 * @param geometry subclass of ShadowGeometry wrapped around a Starling display object.
		 */
		public function addShadowGeometry(geometry:ShadowGeometry):void
		{
			this.geometry.push(geometry);
		}

		/**
		 * remove shadow casting edges for a display object.
		 */
		public function removeGeometryForDisplayObject(object:DisplayObject):void
		{
			for each(var g:ShadowGeometry in geometry)
			{
				if(g.displayObject == object)
				{
					removeShadowGeometry(g);
					return;
				}
			}
		}
		
		/**
		 * remove shadow casting edges directly
		 */
		public function removeShadowGeometry(geometry:ShadowGeometry):void
		{
			this.geometry.splice(this.geometry.indexOf(geometry), 1);
			geometry.dispose();
		}
		
		/**
		 * adds a light source to for shadow casting.
		 * Each light requires two render calls.
		 * @param light Light instance to be added
		 */
		public function addLight(light:LightBase):void
		{
			lights.push(light);
		}

		/**
		 * removes a light source.
		 */
		public function removeLight(light:LightBase):void
		{
			lights.splice(lights.indexOf(light), 1);
		}
		
		/**
		 * change ambient light color and intencity
		 * @param ambientColor color of the ambient light, default black. This does not cast shadows.
		 * @param ambientColorIntencity intencity of the ambient light. Values range from 0 to 1
		 */
		public function setAmbientLightColor(color:uint, intensity:Number = 0):void
		{
			sceneShader.setAmbientColor(color, intensity);
		}

		override public function render(support:RenderSupport, parentAlpha:Number):void
		{
			var context:Context3D = Starling.context;
			
			support.finishQuadBatch();
			if(geometry.length > 0) projectGeometry();
			
			context.setRenderToTexture(lightMapIn, true);
			context.setScissorRectangle(new Rectangle(0, 0, _width, _height));
			context.clear(0, 0, 0, 1, 1, 0, Context3DClearMask.ALL);
			
			context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0, Vector.<Number>([0, 1, 10000, 0]));
			context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 2, projectionMatrix, true);
			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, Vector.<Number>([1, 1, 1, 1]));
			
			for each(var l:LightBase in lights)
			{
				renderLight(l, context);
			}
			
			renderLightMap(context);
			
			context.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);
			context.setVertexBufferAt(0, null);
			context.setVertexBufferAt(1, null);
			context.setTextureAt(0, null);
		}

		private function projectGeometry():void
		{
			const VERTICES_PER_EDGE:uint = 4;
			const INDICES_PER_EDGE:uint = 6;

			var context:Context3D = Starling.context;
			var vertices:Vector.<Number> = new <Number>[];
			var indices:Vector.<uint> = new <uint>[];

			var totalEdgeCount:uint = 0;
			var localEdgeCount:uint = 0;

			var edges:Vector.<Edge>;
			var indexOffset:uint = 0;
			var needsNewBuffer:Boolean;
			
			for each(var shadowGeometry:ShadowGeometry in geometry)
			{
				shadowGeometry.transform();

				edges = shadowGeometry.worldEdges;
				localEdgeCount = edges.length;
				totalEdgeCount += localEdgeCount;
				
				for (var i:uint = 0; i < localEdgeCount; i++)
				{
					var index:uint = i * VERTICES_PER_EDGE + indexOffset;
					var edge:Edge = edges[i];
				
					vertices.push(edge.start.x, edge.start.y, 0, edge.end.x, edge.end.y, 0, edge.end.x, edge.end.y, 1, edge.start.x, edge.start.y, 1);
					indices.push(index, index + 2, index + 1, index, index + 3, index + 2);
				}
				
				indexOffset += (localEdgeCount * VERTICES_PER_EDGE);
			}
			
			needsNewBuffer = !(geometryVertexCount == totalEdgeCount * VERTICES_PER_EDGE);
			
			geometryVertexCount = totalEdgeCount * VERTICES_PER_EDGE;
			
			if(needsNewBuffer)
			{
				if(geometryVertexBuffer) geometryVertexBuffer.dispose();
				geometryVertexBuffer = context.createVertexBuffer(geometryVertexCount, 3);

				if (geometryIndexBuffer) geometryIndexBuffer.dispose();
				geometryIndexBuffer = context.createIndexBuffer(totalEdgeCount * INDICES_PER_EDGE);
			}
			
			geometryVertexBuffer.uploadFromVector(vertices, 0, geometryVertexCount);
			geometryIndexBuffer.uploadFromVector(indices, 0, indices.length);
		}

		private function renderLight(light:LightBase, context:Context3D):void
		{
			context.setDepthTest(false, Context3DCompareMode.ALWAYS);
			
			if(geometry.length > 0) shadowPass(light, context);
			lightPass(light, context);
			
			context.clear(0, 0, 0, 1, 1, 0, Context3DClearMask.STENCIL);
			context.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);
			context.setVertexBufferAt(0, null);
			context.setVertexBufferAt(1, null);
			context.setDepthTest(true, Context3DCompareMode.LESS);
		}

		private function shadowPass(light:LightBase, context:Context3D):void
		{
			switch(true)
			{
				case light is PointLight:
					pointLightShadowShader.setDependencies(geometryVertexBuffer, PointLight(light).x, PointLight(light).y);
					pointLightShadowShader.activate(context);
					break;
				case light is DirectionalLight:
					directionalLightShadowShader.setDependencies(geometryVertexBuffer, light as DirectionalLight);
					directionalLightShadowShader.activate(context);
					break;
				case light is SpotLight:
					pointLightShadowShader.setDependencies(geometryVertexBuffer, SpotLight(light).x, SpotLight(light).y);
					pointLightShadowShader.activate(context);
					break;
				default:
					throw new ArgumentError("unsupported light type");
			}
			
			context.setStencilReferenceValue(1);
			context.setStencilActions(Context3DTriangleFace.FRONT, Context3DCompareMode.ALWAYS, Context3DStencilAction.SET);
			context.setColorMask(false, false, false, false);
			
			context.drawTriangles(geometryIndexBuffer);
		}

		private function lightPass(light:LightBase, context:Context3D):void
		{
			switch(true)
			{
				case light is PointLight:
					pointLightShader.light = light as PointLight;
					pointLightShader.activate(context);
					break;
				case light is DirectionalLight:
					directionalLightShader.light = light as DirectionalLight;
					directionalLightShader.activate(context);
					break;
				case light is SpotLight:
					spotLightShader.light = light as SpotLight;
					spotLightShader.activate(context);
					break;
				default:
					throw new ArgumentError("unsupported light type");
			}

			context.setStencilReferenceValue(0);
			context.setStencilActions(Context3DTriangleFace.FRONT, Context3DCompareMode.EQUAL, Context3DStencilAction.KEEP);
			context.setColorMask(true, true, true, true);
			context.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE);			
			
			context.drawTriangles(sceneIndexBuffer);
		}

		private function renderLightMap(context:Context3D):void
		{
			blurShader.activate(context);
			context.drawTriangles(sceneIndexBuffer);
			
			blurShader.activateSecondPass(context);			
			context.drawTriangles(sceneIndexBuffer);
			
			context.setRenderToBackBuffer();
			context.setDepthTest(false, Context3DCompareMode.ALWAYS);
			context.setScissorRectangle(null);
			
			sceneShader.activate(context);
			context.setBlendFactors(Context3DBlendFactor.DESTINATION_COLOR, Context3DBlendFactor.ZERO);
			context.drawTriangles(sceneIndexBuffer);
		}

		override public function getBounds(targetSpace:DisplayObject, resultRect:Rectangle = null):Rectangle
		{
			var rect:Rectangle = new Rectangle(0, 0, _width, _height);

			return rect;
		}

		public override function dispose():void
		{
			sceneVertexBuffer.dispose();
			sceneUVBuffer.dispose();
			sceneIndexBuffer.dispose();

			geometryVertexBuffer.dispose();
			geometryIndexBuffer.dispose();
			
			lightMapIn.dispose();
		}

		private function nextPowerOfTwo(n:uint):uint
		{
			n = n - 1;
			n = n | (n >> 1);
			n = n | (n >> 2);
			n = n | (n >> 4);
			n = n | (n >> 8);
			n = n | (n >> 16);
			n = n + 1;
			
			return n;
		}
	}
}
