final int DIMENSIONS = 4; // 2 complex numbers (x and y): 1 real and 1 imaginary each).
final int DIMENSIONS_CAMERA = 2;
final int ROTATION_DIMENSION = 2; //Rotate around this dimension's axis.
float rotationAngle = .2 * PI;

final float CAMERA_SIZE = 800;

final float EDGE_LENGTH = 200;

final double MOVE_STEP = 5;

class Complex {
  public final double real;
  public final double i;
  
  public Complex(double real, double i) {
      this.real = real;
      this.i = i;
  }
  
  public Complex multiply(final Complex b) {
      final double real = this.real * b.real - this.i * b.i;
      final double i = this.real * b.i + this.i * b.real;
      return new Complex(real, i);
  }
  
  public Complex add(final Complex b) {
      final double real = this.real + b.real;
      final double i = this.i * b.i;
      return new Complex(real, i);
  }
}

class VerticesSet {
  public final ArrayList<float[]> vertices = new ArrayList<float[]>();
  public color drawingColor = 0;
};

final ArrayList<VerticesSet> sets = new ArrayList<VerticesSet>();

//The top-left corner of the camera, in the z plane:
final float[] cameraCorner = newVertex(DIMENSIONS);

final float[] cameraSize = newVertex(DIMENSIONS_CAMERA);

//z distance of focus point behind the camera plane:
float focalLength = 1000; 


float[] newVertex(final float[] offset, final int dimensions) {
  final float[] result = newVertex(dimensions);
  arrayCopy(offset, result);
  return result;
}

float[] newVertex(final int dimensions) {
  final float[] result = new float[dimensions]; //Apparently initialized to 0s.
  return result;
}

void addAxesLines(final ArrayList<VerticesSet> sets, final float[] offset, final int dimensions) {
  final float MIN = -1000;
  final float MAX = 1000;
  for(int i = 0; i < dimensions; ++i) {
    final VerticesSet set = new VerticesSet();
    addAxisLine(set.vertices, offset, dimensions, i);
    set.drawingColor = color(50, 55, 100);
    sets.add(set);
  }
}
  
void addAxisLine(final ArrayList<float[]> vertices, final float[] offset, final int dimensions, final int dimension) {
  final float RANGE = 1000;
  
  float[] vertex = newVertex(offset, dimensions);
  vertex[dimension] -= RANGE;
  vertices.add(vertex);
    
  vertex = newVertex(offset, dimensions);
  vertex[dimension] += RANGE;
  vertices.add(vertex);
}

/**
 * @param coefficients An array of coefficients, stating with the higher power.
 * For instance a, b, and c in a * x^2 + b * x^1 + c * x^0.
 */
Complex calcQuadratic(final Complex[] coefficients, final Complex x) {
  Complex result = new Complex(0, 0);
  
  int power = coefficients.length - 1;
  for (final Complex coefficient : coefficients) {
    Complex val = null;
    if (power == 0) {
      val = new Complex(1, 0);
    } else {
      val = x;
      for (int i = 1 ; i < power; i++) {
        val = val.multiply(val);
      }
    }
    
    val = val.multiply(coefficient);
    
    result = result.add(val);
    
    --power;
  }
  
  return result;
}

void addQuadraticPlot(final ArrayList<VerticesSet> sets, final float[] offset, final int dimensions) {
  final Complex[] coefficients = new Complex[3];
  coefficients[0] = new Complex (-0.02, 0);
  coefficients[1] = new Complex (-0.02, 0);
  coefficients[2] = new Complex (-10, 0);


  final float MIN = -100;
  final float MAX = 100;
  for(float realX = MIN; realX <= MAX; realX += 1) {
    
    VerticesSet set = new VerticesSet();
    set.drawingColor = color(204, 153, 0, 50);
    sets.add(set);
    final ArrayList<float[]> vertices = set.vertices;
  
    for (float iX = MIN; iX < MAX; iX +=1) {
      final Complex x = new Complex(realX, iX);
      final Complex y = calcQuadratic(coefficients, x);
      
      final float[] vertex = newVertex(offset, dimensions);
      vertex[0] += x.real;
      vertex[1] += y.real;
      vertex[2] += x.i;
      vertex[3] += y.i;
      vertices.add(vertex);
    }
  }
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

void addCube(final ArrayList<float[]> vertices, final float[] offset, final int dimensions, final float edgeLength) {
  for (int dimension = 0; dimension < dimensions; ++dimension) {
    addCubeSides(vertices, offset, dimensions, edgeLength, dimension);
  }
}

void settings() {
  size((int)CAMERA_SIZE, (int)CAMERA_SIZE);
}

void setup() {
  
  cameraCorner[0] = -(CAMERA_SIZE / 2);
  cameraCorner[1] = -(CAMERA_SIZE / 2);

  for (int i = 0; i < DIMENSIONS_CAMERA; ++i) {
    cameraSize[i] = CAMERA_SIZE;
  }

  noSmooth();
  
  final float[] offset = newVertex(DIMENSIONS); //{CAMERA_SIZE / 2 - (EDGE_LENGTH / 2), CAMERA_SIZE / 2 - (EDGE_LENGTH / 2), 300};
  addAxesLines(sets, offset, DIMENSIONS);
  
  addQuadraticPlot(sets, offset, DIMENSIONS);

  
  /*
  VerticesSet set = new VerticesSet();
  final float[] offset1 = {CAMERA_SIZE / 2 - (EDGE_LENGTH / 2), CAMERA_SIZE / 2 - (EDGE_LENGTH / 2), 300};
  addCube(set.vertices, offset1, DIMENSIONS, EDGE_LENGTH);
  set.drawingColor = color(204, 153, 0);
  sets.add(set);
  
  set = new VerticesSet();
  final float[] offset2 = {300, 600, 400};
  addCube(set.vertices, offset2, DIMENSIONS, 250);
  set.drawingColor = color(50, 55, 100);
  sets.add(set);
  */
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
   case 'r':
   case 'R':
     rotationAngle -= 0.01 * PI;
     break;
   default:
     break;
  }
}

ArrayList<VerticesSet> rotate(final ArrayList<VerticesSet> sets, int dimensions, int rotationDimension) {
  ArrayList<VerticesSet> result = new ArrayList<VerticesSet>();
  
 for (final VerticesSet set : sets) {
    final VerticesSet setResult = new VerticesSet();
    setResult.drawingColor = set.drawingColor;
    result.add(setResult);
    
    final ArrayList<float[]> vertices = set.vertices;
    final ArrayList<float[]> verticesResult = setResult.vertices;
    
    //TODO: Generalize this to n dimensions,
    //though rotation in 4 dimensions would maybe be somehow around a plane rather than around a line.
    //
    //Figure out which dimensions' values need to change.
    //(all dimensions other than the one whose axis we are rotating around):
    final int[] dimensionsToRotate = new int[2];
    int dimensionsToRotateIndex = 0;
    for (int i = 0; i < dimensions; ++i) {
        if (i != rotationDimension) {
          dimensionsToRotate[dimensionsToRotateIndex] = i;
          ++dimensionsToRotateIndex;
        }
    }
      
    for (float[] vertex : vertices) {  
      final float val1 = vertex[dimensionsToRotate[0]];
      final float val2 = vertex[dimensionsToRotate[1]];

      final float[] vertexResult = newVertex(vertex, dimensions);
      vertexResult[dimensionsToRotate[0]] = val1 * cos(rotationAngle) - val2 * sin(rotationAngle);
      vertexResult[dimensionsToRotate[1]] = val1 * sin(rotationAngle) + val2 * cos(rotationAngle);
      
      verticesResult.add(vertexResult);
    }
 }
 
  return result;
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
  
  surface.setTitle(mouseX + ", " + mouseY);
  
  final ArrayList<VerticesSet> setsRotated = sets; //rotate(sets, DIMENSIONS, ROTATION_DIMENSION);
  
  //Project it until we are down to 2D:
  //Of course, a real 3D API would do a better job of showing this as soon as it's down to 3D.
  ArrayList<VerticesSet> setsProjected = setsRotated;
  for (int dimensions = DIMENSIONS; dimensions > DIMENSIONS_CAMERA; --dimensions) {
    setsProjected = projectToPlane(setsProjected, dimensions, dimensions -1);
  }

  for (final VerticesSet set : setsProjected) {
    //strokeWeight(0.001);
    stroke(set.drawingColor);
    
    float[] previousPoint = null;
    final ArrayList<float[]> vertices = set.vertices;
    for (final float[] vertex : vertices) {
      //point(vertex[0], vertex[1]);
    
      if (previousPoint != null) {
        line(previousPoint[0], previousPoint[1],
          vertex[0], vertex[1]);
      }
      
      previousPoint = vertex;
    }
  }
}