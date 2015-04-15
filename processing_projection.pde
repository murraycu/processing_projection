final int DIMENSIONS = 3;
final int DIMENSIONS_CAMERA = DIMENSIONS - 1;

final float CAMERA_WIDTH = 1000;
final float CAMERA_HEIGHT = 800;

// Vertices of a cube: x, y, z
final float EDGE_LENGTH = 200;

final double MOVE_STEP = 5;


final ArrayList<float[]> vertices = new ArrayList<float[]>();

//The top-left corner of the camera, in the z plane:
final float[] camera_corner = {0, 0, 0};
final float[] camera_size = {CAMERA_WIDTH, CAMERA_HEIGHT};

//z distance of focus point behind the camera plane:
float focal_length = 100; 

final float[] OFFSET = {CAMERA_WIDTH / 2 - (EDGE_LENGTH / 2), CAMERA_HEIGHT / 2 - (EDGE_LENGTH / 2), 300};

float[] newVertex(float[] offset) {
  final float[] result = new float[]{0, 0, 0};
  arrayCopy(offset, result);
  return result;
}
/**
 * Add opposite squares (cube sides) in the plane of this dimension.
 */
void add_cube_sides(final ArrayList<float[]> vertices, final float[] offset, final float edge_length, final int dimension)
{
  //For instance, draw with x and y values if we are drawing on the z plane:
  int dimension1 = dimension + 1;
  if (dimension1 >= DIMENSIONS) {
    dimension1 = 0;
  }
    
  int dimension2 = dimension1 + 1;
  if (dimension2 >= DIMENSIONS) {
    dimension2 = 0;
  }
  
  //println("dimension=" + dimension + ", dimension1=" + dimension1 + ", dimension2=" + dimension2);
  
  for (int i = 0; i < 2; ++i) {
    final float[] offsetSide = new float[DIMENSIONS];
    arrayCopy(offset, offsetSide);
    final float OFFSET_FROM_PLANE = i * edge_length;
    offsetSide[dimension] += OFFSET_FROM_PLANE;
    
    float[] vertex = newVertex(offsetSide);
    vertex[dimension1] += 0;
    vertex[dimension2] += 0;
    vertices.add(vertex);
  
    vertex = newVertex(offsetSide);
    vertex[dimension1] += edge_length;
    vertex[dimension2] += 0;
    vertices.add(vertex);
     
    vertex = newVertex(offsetSide);
    vertex[dimension1] += edge_length;
    vertex[dimension2] += edge_length;
    vertices.add(vertex);
     
    vertex = newVertex(offsetSide);
    vertex[dimension1] += 0;
    vertex[dimension2] += edge_length;
    vertices.add(vertex);
     
    vertex = newVertex(offsetSide);
    vertex[dimension1] += 0;
    vertex[dimension2] += 0;
    vertices.add(vertex);
  }
}

void add_cube_sides(final ArrayList<float[]> vertices, final float[] offset, final float edge_length) {
  for (int dimension = 0; dimension < DIMENSIONS; ++dimension) {
    add_cube_sides(vertices, offset, edge_length, dimension);
  }
}
  
void setup() {
  size((int)CAMERA_WIDTH, (int)CAMERA_HEIGHT);
  noSmooth();
 
  add_cube_sides(vertices, OFFSET, EDGE_SIZE);
}

void keyPressed()
{ 
  //Use the arrow keys to move our focus point (where we are standing)
  //Remember that the origin is at the top-left, increasing downards and to the right:
  switch(keyCode) {
   case LEFT:
     camera_corner[0] -= MOVE_STEP;
    break;
   case RIGHT:
     camera_corner[0] += MOVE_STEP;
     break;
   case UP:
     camera_corner[1] -= MOVE_STEP;
     break;
   case DOWN:
     camera_corner[1] += MOVE_STEP;
     break;
   case 'q':
   case 'Q':
     camera_corner[2]+= MOVE_STEP;
     break;
   case 'a':
   case 'A':
     camera_corner[2] -= MOVE_STEP;
     break;
   case 'p':
   case 'P':
     focal_length += MOVE_STEP;
     break;
   case 'l':
   case 'L':
     focal_length -= MOVE_STEP;
     break;
   default:
     break;
  }
}

void draw() {
  background(255);
  
  frame.setTitle(mouseX + ", " + mouseY);

  float[] previous_point = null;
  //println(" z=" + focus_point[2]);
  
  //The focal point:
  final float[] real_focus = new float[DIMENSIONS];
  for (int i = 0 ; i < DIMENSIONS_CAMERA; ++i) { 
    real_focus[i] = camera_corner[i] + (camera_size[i] / 2);
  }
  final float camera_z = camera_corner[DIMENSIONS - 1];
  final float real_focus_z = camera_z - focal_length;
  real_focus[DIMENSIONS - 1] = real_focus_z;
  
  for (float[] vertex : vertices) {
    //Calculate the ratio of the z from the focus-point-to-camera to focus-point-to-vertex:
    //TODO: Avoid division by zero:
    final float ratio_z = (camera_z - real_focus_z) /
      (vertex[DIMENSIONS - 1] - real_focus_z);
    //println("ratio_z: " + ratio_z);
    
    final float[] camera_points = new float[DIMENSIONS_CAMERA];
    for (int i = 0 ; i < DIMENSIONS_CAMERA; ++i) {
      final float vertex_pos = vertex[i];
      final float focus_pos = real_focus[i];
      final float projected_pos = focus_pos + (vertex_pos - focus_pos) * ratio_z;
      camera_points[i] = projected_pos - camera_corner[i];
    }
    
    if (previous_point != null) {
      line(previous_point[0], previous_point[1],
        camera_points[0], camera_points[1]);
    }
  
    previous_point = new float[] {camera_points[0], camera_points[1]};
  }
}




