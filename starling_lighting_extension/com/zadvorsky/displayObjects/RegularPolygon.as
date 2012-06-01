package com.zadvorsky.displayObjects
{
	import com.adobe.utils.AGALMiniAssembler;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DClearMask;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DRenderMode;
	import flash.display3D.Context3DStencilAction;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.Context3DTriangleFace;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Orientation3D;
	import flash.geom.PerspectiveProjection;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Transform;
	import flash.geom.Utils3D;
	import flash.geom.Vector3D;
	import starling.core.RenderSupport;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.errors.MissingContextError;
	import starling.events.Event;
	import starling.utils.VertexData;



	/** This custom display objects renders a regular, n-sided polygon. */
	public class RegularPolygon extends DisplayObject
	{
		private static var PROGRAM_NAME:String = "polygon";

		private var mRadius:Number;
		private var mNumEdges:int;
		private var mColor:uint;

		private var mVertexData:VertexData;
		private var mVertexBuffer:VertexBuffer3D;

		private var mIndexData:Vector.<uint>;
		private var mIndexBuffer:IndexBuffer3D;

		private static var sHelperMatrix:Matrix = new Matrix();
		private static var sRenderAlpha:Vector.<Number> = new <Number>[1.0, 1.0, 1.0, 1.0];
		
		public function RegularPolygon(radius:Number, numEdges:int = 6, color:uint = 0xffffff)
		{
			if(numEdges < 3) throw new ArgumentError("Invalid number of edges");

			mRadius = radius;
			mNumEdges = numEdges;
			mColor = color;

			setupVertices();
			createBuffers();
			registerPrograms();

			Starling.current.addEventListener(Event.CONTEXT3D_CREATE, onContextCreated);
		}

		public override function dispose():void
		{
			Starling.current.removeEventListener(Event.CONTEXT3D_CREATE, onContextCreated);

			if(mVertexBuffer) mVertexBuffer.dispose();
			if(mIndexBuffer) mIndexBuffer.dispose();

			super.dispose();
		}

		private function onContextCreated(event:Event):void
		{
			createBuffers();
			registerPrograms();
		}

		public override function getBounds(targetSpace:DisplayObject, resultRect:Rectangle = null):Rectangle
		{
			if(resultRect == null) resultRect = new Rectangle();

			var transformationMatrix:Matrix = targetSpace == this ? null : getTransformationMatrix(targetSpace, sHelperMatrix);

			return mVertexData.getBounds(transformationMatrix, 0, -1, resultRect);
		}

		private function setupVertices():void
		{
			var i:int;

			mVertexData = new VertexData(mNumEdges + 1);
			mVertexData.setUniformColor(mColor);

			for(i = 0; i < mNumEdges; ++i)
			{
				var edge:Point = Point.polar(mRadius, i * 2 * Math.PI / mNumEdges);
				mVertexData.setPosition(i, edge.x, edge.y);
			}

			mVertexData.setPosition(mNumEdges, 0.0, 0.0);

			mIndexData = new <uint>[];

			for(i = 0; i < mNumEdges; ++i)
			{
				mIndexData.push(mNumEdges, i, (i + 1) % mNumEdges);
			}
		}

		private function createBuffers():void
		{
			var context:Context3D = Starling.context;
			if(context == null) throw new MissingContextError();

			if(mVertexBuffer) mVertexBuffer.dispose();
			if(mIndexBuffer) mIndexBuffer.dispose();

			mVertexBuffer = context.createVertexBuffer(mVertexData.numVertices, VertexData.ELEMENTS_PER_VERTEX);
			mVertexBuffer.uploadFromVector(mVertexData.rawData, 0, mVertexData.numVertices);

			mIndexBuffer = context.createIndexBuffer(mIndexData.length);
			mIndexBuffer.uploadFromVector(mIndexData, 0, mIndexData.length);
		}

		public override function render(support:RenderSupport, alpha:Number):void
		{
			support.finishQuadBatch();
			
			sRenderAlpha[0] = sRenderAlpha[1] = sRenderAlpha[2] = 1.0;
			sRenderAlpha[3] = alpha * this.alpha;

			var context:Context3D = Starling.context;
			if(context == null) throw new MissingContextError();

			support.applyBlendMode(false);

			context.setProgram(Starling.current.getProgram(PROGRAM_NAME));
			context.setVertexBufferAt(0, mVertexBuffer, VertexData.POSITION_OFFSET, Context3DVertexBufferFormat.FLOAT_3);
			context.setVertexBufferAt(1, mVertexBuffer, VertexData.COLOR_OFFSET, Context3DVertexBufferFormat.FLOAT_4);
			context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, support.mvpMatrix3D, true);
			context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 4, sRenderAlpha, 1);

			context.drawTriangles(mIndexBuffer, 0, mNumEdges);

			context.setVertexBufferAt(0, null);
			context.setVertexBufferAt(1, null);
		}

		/** Creates vertex and fragment programs from assembly. */
		private static function registerPrograms():void
		{
			var target:Starling = Starling.current;
			if(target.hasProgram(PROGRAM_NAME)) return;

			var vertexProgramCode:String = 
			"m44 op, va0, vc0 \n" +
			"mul v0, va1, vc4 \n";
			
			var fragmentProgramCode:String = 
			"mov oc, v0";

			var vertexProgramAssembler:AGALMiniAssembler = new AGALMiniAssembler();
			vertexProgramAssembler.assemble(Context3DProgramType.VERTEX, vertexProgramCode);

			var fragmentProgramAssembler:AGALMiniAssembler = new AGALMiniAssembler();
			fragmentProgramAssembler.assemble(Context3DProgramType.FRAGMENT, fragmentProgramCode);

			target.registerProgram(PROGRAM_NAME, vertexProgramAssembler.agalcode, fragmentProgramAssembler.agalcode);
		}

		public function get radius():Number
		{
			return mRadius;
		}

		public function set radius(value:Number):void
		{
			mRadius = value;
			setupVertices();
		}

		public function get numEdges():int
		{
			return mNumEdges;
		}

		public function set numEdges(value:int):void
		{
			mNumEdges = value;
			setupVertices();
		}

		public function get color():uint
		{
			return mColor;
		}

		public function set color(value:uint):void
		{
			mColor = value;
			setupVertices();
		}

		public function get vertexData():VertexData
		{
			return mVertexData;
		}
	}
}