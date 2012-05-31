package starling.extentions.lighting.core
{
	import starling.core.RenderSupport;
	import starling.display.DisplayObject;

	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;

	/**
	 * @author Szenia Zadvornykh
	 */
	public class ShadowGeometry
	{
		private var _modelEdges:Vector.<Edge>;
		private var _worldEdges:Vector.<Edge>;
		
		private var _displayObject:DisplayObject;
		
		private var tempTransformationMatrix:Matrix3D;
		
		/**
		 * abstract baseclass to hold geometry used for shadow casting
		 * do NOT use this class, instead use QuadShadowGeometry, RegularPolygonShadowGeometry or your own implementation
		 */
		public function ShadowGeometry(displayObject:DisplayObject)
		{
			_displayObject = displayObject;
			
			tempTransformationMatrix = new Matrix3D();
			
			_modelEdges = createEdges();
			_worldEdges = new <Edge>[];
			
			for each(var edge:Edge in _modelEdges)
			{
				_worldEdges.push(new Edge(new Vector3D, new Vector3D()));
			}
		}
		
		/**
		 * override this method in a custom implementation to create more complex geometry
		 */
		protected function createEdges():Vector.<Edge>
		{
			return null;
		}
		
		final public function transform():void
		{
			tempTransformationMatrix.identity();
			
			RenderSupport.transformMatrixForObject(tempTransformationMatrix, _displayObject);
			
			var modelEdge:Edge;
			var worldEdge:Edge;
			
			for (var i:int; i < _modelEdges.length; i++)
			{
				modelEdge = _modelEdges[i];
				worldEdge = _worldEdges[i];
				
				worldEdge.start = tempTransformationMatrix.transformVector(modelEdge.start);
				worldEdge.end = tempTransformationMatrix.transformVector(modelEdge.end);
			}
		}

		final public function get worldEdges():Vector.<Edge>
		{
			return _worldEdges;
		}

		final public function get displayObject():DisplayObject
		{
			return _displayObject;
		}

		public function dispose():void
		{
			_displayObject = null;
			_modelEdges = null;
			_worldEdges = null;
			tempTransformationMatrix = null;
		}
	}
}
