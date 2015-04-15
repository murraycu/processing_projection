final int DIMENSIONS = 3;
final int DIMENSIONS_CAMERA = 2;

final float CAMERA_SIZE = 800;

// Vertices of a cube: x, y, z
final float EDGE_LENGTH = 200;

final double MOVE_STEP = 5;

class VerticesSet {
  public final ArrayList<float[]> vertices = new ArrayList<float[]>();
  public color drawingColor = 0;
};

final ArrayList<VerticesSet> sets = new ArrayList<VerticesSet>();

//The top-left corner of the camera, in the z plane:
final float[] cameraCorner = newVertex(DIMENSIONS);
final float[] cameraSize = newVertex(DIMENSIONS_CAMERA);

//z distance of focus point behind the camera plane:
float focalLength = 500; 


float[] newVertex(final float[] offset, final int dimensions) {
  final float[] result = newVertex(dimensions);
  arrayCopy(offset, result);
  return result;
}

float[] newVertex(final int dimensions) {
  final float[] result = new float[dimensions]; //Apparently initialized to 0s.
  return result;
}

/**
 * Add opposite squares (cube sides) in the plane of this dimension.
 */
void addCubeSides(final ArrayList<float[]> vertices, final float[] offset, final int dimensions, final float edgeLength, final int dimension)
{  
  //println("dimension=" + dimension + ", dimension1=" + dimension1 + ", dimension2=" + dimension2);

  for (int i = 0; i < 2; ++i) {
    //println("Side:");
    final float[] offsetSide = new float[DIMENSIONS];
    arrayCopy(offset, offsetSide);
    final float OFFSET_FROM_PLANE = i * edgeLength;
    offsetSide[dimension] += OFFSET_FROM_PLANE;

    //Generate a series of vertices, adding the edge length to each dimension in turn:
    float[] vertex = newVertex(offsetSide, dimensions);
    float[] vertexStart = null;
    for (int j = 0; j < dimensions; ++j) {
      if (j == dimension) {
        continue;
      }

      vertex[j] += edgeLength;

      final float[] v = newVertex(vertex, dimensions);
      vertices.add(v);
      //println("  vertex: " + v[0] + ", " + v[1] + ", " + v[2]);

      if (vertexStart == null) {
        vertexStart = newVertex(v, dimensions);
      }
    }

    //Generate a series of vertices, removing the edge length from each dimension in turn:
    for (int j = 0; j < dimensions; ++j) {
      if (j == dimension) {
        continue;
      }

      vertex[j] -= edgeLength;

      float[] v = newVertex(vertex, dimensions);
      vertices.add(v);
      //println("  vertex: " + v[0] + ", " + v[1] + ", " + v[2]);
    }

    //And back to the start:
    vertices.add(vertexStart);
    //println("  vertexStart: " + vertexStart[0] + ", " + vertexStart[1] + ", " + vertexStart[2]);
  }
}

void addCubeSides(final ArrayList<float[]> vertices, final float[] offset, final int dimensions, final float edgeLength) {
  for (int dimension = 0; dimension < dimensions; ++dimension) {
    addCubeSides(vertices, offset, dimensions, edgeLength, dimension);
  }
}

void setup() {
  size((int)CAMERA_SIZE, (int)CAMERA_SIZE);
  
  for (int i = 0; i < DIMENSIONS_CAMERA; ++i) {
    cameraSize[i] = CAMERA_SIZE;
  }

  noSmooth();
  
  VerticesSet set = new VerticesSet();
  final float[] offset1 = {CAMERA_SIZE / 2 - (EDGE_LENGTH / 2), CAMERA_SIZE / 2 - (EDGE_LENGTH / 2), 300};
  addCubeSides(set.vertices, offset1, DIMENSIONS, EDGE_LENGTH);
  set.drawingColor = color(204, 153, 0);
  sets.add(set);
  
  set = new VerticesSet();
  final float[] offset2 = {300, 600, 400};
  addCubeSides(set.vertices, offset2, DIMENSIONS, 250);
  set.drawingColor = color(50, 55, 100);
  sets.add(set);
}

void keyPressed()
{ 
  //Use the arrow keys to move our focus point (where we are standing)
  //Remember that the origin is at the top-left, increasing downards and to the right:
  switch(keyCode) {
   case LEFT:
     cameraCorner[0] -= MOVE_STEP;
    break;
   case RIGHT:
     cameraCorner[0] += MOVE_STEP;
     break;
   case UP:
     cameraCorner[1] -= MOVE_STEP;
     break;
   case DOWN:
     cameraCorner[1] += MOVE_STEP;
     break;
   case 'q':
   case 'Q':
     cameraCorner[2]+= MOVE_STEP;
     break;
   case 'a':
   case 'A':
     cameraCorner[2] -= MOVE_STEP;
     break;
   case 'p':
   case 'P':
     focalLength += MOVE_STEP;
     break;
   case 'l':
   case 'L':
     focalLength -= MOVE_STEP;
     break;
   default:
     break;
  }
}

ArrayList<VerticesSet> projectToPlane(final ArrayList<VerticesSet> sets, int dimensions, int dimensionsPlane) {
  ArrayList<VerticesSet> result = new ArrayList<VerticesSet>();
  
  //The focal point:
  final float[] realFocus = newVertex(DIMENSIONS);
  for (int i = 0 ; i < DIMENSIONS_CAMERA; ++i) { 
    realFocus[i] = cameraCorner[i] + (cameraSize[i] / 2);
  }
  final float cameraZ = cameraCorner[DIMENSIONS - 1];
  final float realFocusZ = cameraZ - focalLength;
  realFocus[DIMENSIONS - 1] = realFocusZ;
    
  for (final VerticesSet set : sets) {
    final VerticesSet setResult = new VerticesSet();
    setResult.drawingColor = set.drawingColor;
    result.add(setResult);
    
    stroke(set.drawingColor);
    final ArrayList<float[]> vertices = set.vertices;
    final ArrayList<float[]> verticesResult = setResult.vertices;
      
    for (float[] vertex : vertices) {
      //Calculate the ratio of the z from the focus-point-to-camera to focus-point-to-vertex:
      //TODO: Avoid division by zero:
      final float ratioZ = (cameraZ - realFocusZ) /
        (vertex[dimensions - 1] - realFocusZ);
      
      final float[] cameraPoints = newVertex(dimensionsPlane);
      for (int i = 0 ; i < dimensionsPlane; ++i) {
        final float vertex_pos = vertex[i];
        final float focus_pos = realFocus[i];
        final float projectedPos = focus_pos + (vertex_pos - focus_pos) * ratioZ;
        cameraPoints[i] = projectedPos - cameraCorner[i];
      }
      
      verticesResult.add(cameraPoints);
    }
  }
  
  return result;
}

void draw() {
  background(255);
  
  frame.setTitle(mouseX + ", " + mouseY);
  
  //Project it until we are down to 2D:
  //Of course, a real 3D API would do a better job of showing this as soon as it's down to 3D.
  ArrayList<VerticesSet> setsProjected = sets;
  for (int dimensions = DIMENSIONS; dimensions > DIMENSIONS_CAMERA; --dimensions) {
    setsProjected = projectToPlane(setsProjected, dimensions, dimensions -1);
  }

  for (final VerticesSet set : setsProjected) {
    stroke(set.drawingColor);
    
    float[] previousPoint = null;
    final ArrayList<float[]> vertices = set.vertices;
    for (final float[] vertex : vertices) {
      
      if (previousPoint != null) {
        line(previousPoint[0], previousPoint[1],
          vertex[0], vertex[1]);
      }
      
      previousPoint = vertex;
    }
  }
}




