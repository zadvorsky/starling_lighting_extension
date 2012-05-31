package starling.extensions.lighting.geometry
{
	import starling.extensions.lighting.core.Edge;
	import starling.extensions.lighting.core.ShadowGeometry;
	import starling.utils.VertexData;

	import com.zadvorsky.displayObjects.RegularPolygon;

	import flash.geom.Point;
	import flash.geom.Vector3D;



	/**
	 * @author Szenia Zadvornykh
	 */
	public class RegularPolygonShadowGeometry extends ShadowGeometry
	{
		/**
		 * subclass of ShadowGeometry that creates shadow geometry matching the vertex data of a RegularPolygon
		 * @param displayObject RegularPolygon instance the shadow geometry will be created for
		 */
		public function RegularPolygonShadowGeometry(displayObject:RegularPolygon)
		{
			super(displayObject);
		}
		
		override protected function createEdges():Vector.<Edge>
		{
			var polygon:RegularPolygon = displayObject as RegularPolygon;
			var vertexData:VertexData = polygon.vertexData;
			var numEdges:int = vertexData.numVertices - 1 / 2;
			
			var edges:Vector.<Edge> = new <Edge>[];
			
			var current:Point = new Point();
			var next:Point = new Point();
			
			for (var i:int = 0; i < numEdges - 1; i++)
			{
				vertexData.getPosition(i, current);
				vertexData.getPosition(i + 1, next);
				
				edges.push(new Edge(new Point(current.x, current.y),new Point(next.x, next.y)));
			}
			
			vertexData.getPosition(i, current);
			vertexData.getPosition(0, next);
			
			edges.push(new Edge(new Point(current.x, current.y),new Point(next.x, next.y)));
			
			return edges;
		}
	}
}
