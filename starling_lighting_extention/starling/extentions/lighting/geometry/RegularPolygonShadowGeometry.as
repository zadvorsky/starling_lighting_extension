package starling.extentions.lighting.geometry
{
	import com.zadvorsky.displayObjects.RegularPolygon;
	import flash.geom.Vector3D;
	import starling.extentions.lighting.core.Edge;
	import starling.extentions.lighting.core.ShadowGeometry;
	import starling.utils.VertexData;



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
			
			var current:Vector3D = new Vector3D();
			var next:Vector3D = new Vector3D();
			
			for (var i:int = 0; i < numEdges - 1; i++)
			{
				vertexData.getPosition(i, current);
				vertexData.getPosition(i + 1, next);
				
				edges.push(new Edge(new Vector3D(current.x, current.y),new Vector3D(next.x, next.y)));
			}
			
			vertexData.getPosition(i, current);
			vertexData.getPosition(0, next);
			
			edges.push(new Edge(new Vector3D(current.x, current.y),new Vector3D(next.x, next.y)));
			
			return edges;
		}
	}
}
