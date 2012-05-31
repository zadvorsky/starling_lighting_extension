package starling.extentions.lighting.geometry
{
	import flash.geom.Vector3D;
	import starling.display.DisplayObject;
	import starling.display.Quad;
	import starling.extentions.lighting.core.Edge;
	import starling.extentions.lighting.core.ShadowGeometry;
	import starling.utils.VertexData;


	/**
	 * @author Szenia Zadvornykh
	 */
	public class QuadShadowGeometry extends ShadowGeometry
	{
		/**
		 * subclass of ShadowGeometry that creates shadow geometry matching the vertex data (bounding box) of a Quad or Image instance
		 * @param displayObject Quad or Image instance the shadow geometry will be created for
		 */
		public function QuadShadowGeometry(displayObject:Quad)
		{
			super(displayObject);
		}

		override protected function createEdges():Vector.<Edge>
		{
			const indices:Array = [0, 1, 1, 3, 3, 2, 2, 0];
			const numEdges:int = 4;
			
			var quad:Quad = displayObject as Quad;
			var vertexData:VertexData = new VertexData(4);
			quad.copyVertexDataTo(vertexData);
			
			var edges:Vector.<Edge> = new <Edge>[];
			
			var start:Vector3D;
			var end:Vector3D;
			var index:int;
			
			for(var i:int; i < numEdges; i++)
			{
				index = i * 2;
				
				start = new Vector3D();
				end = new Vector3D();
				
				vertexData.getPosition(indices[index], start)		
				vertexData.getPosition(indices[index + 1], end);
				
				edges.push(new Edge(start, end));		
			}
			
			return edges;
		}
	}
}
