final int DIMENSIONS = 3;
final int DIMENSION_CAMERA_PLANE = 3;
final int VERTICES_COUNT = 15;
final float[][] vertices = new float[VERTICES_COUNT][DIMENSIONS];

float camera_z = 0;
//focus_point z is z behind the camera
final float[] focus_point = {100, 100, -100};

// Vertices of a cube: x, y, z
final float EDGE_LENGTH = 300;
final float X_DISTANCE = 200;
final float Y_DISTANCE = 200;
final float Z_DISTANCE = 200;

void setup() {
  size(640, 480);
  noSmooth();
 
  vertices[0] = new float[]{X_DISTANCE, Y_DISTANCE, Z_DISTANCE}; //Start front side
  vertices[1] = new float[]{X_DISTANCE, Y_DISTANCE + EDGE_LENGTH, Z_DISTANCE};
  vertices[2] = new float[]{X_DISTANCE + EDGE_LENGTH, Y_DISTANCE + EDGE_LENGTH, Z_DISTANCE};
  vertices[3] = new float[]{X_DISTANCE + EDGE_LENGTH, Y_DISTANCE, Z_DISTANCE};
  vertices[4] = new float[]{X_DISTANCE, Y_DISTANCE, Z_DISTANCE}; //Finish front side.
  vertices[5] = new float[]{X_DISTANCE, Y_DISTANCE, Z_DISTANCE}; //Finish front side.
  vertices[6] = new float[]{X_DISTANCE, Y_DISTANCE, Z_DISTANCE + EDGE_LENGTH}; //Start left side
  vertices[7] = new float[]{X_DISTANCE, Y_DISTANCE + EDGE_LENGTH, Z_DISTANCE + EDGE_LENGTH};
  vertices[8] = new float[]{X_DISTANCE, Y_DISTANCE + EDGE_LENGTH, Z_DISTANCE};
  vertices[9] = new float[]{X_DISTANCE, Y_DISTANCE, Z_DISTANCE}; //Finish left side.
  vertices[10] = new float[]{X_DISTANCE, Y_DISTANCE + EDGE_LENGTH, Z_DISTANCE}; //Start top side.
  vertices[11] = new float[]{X_DISTANCE, Y_DISTANCE + EDGE_LENGTH, Z_DISTANCE + EDGE_LENGTH};
  vertices[12] = new float[]{X_DISTANCE + EDGE_LENGTH, Y_DISTANCE + EDGE_LENGTH, Z_DISTANCE + EDGE_LENGTH};
  vertices[13] = new float[]{X_DISTANCE + EDGE_LENGTH, Y_DISTANCE + EDGE_LENGTH, Z_DISTANCE};
  vertices[14] = new float[]{X_DISTANCE, Y_DISTANCE + EDGE_LENGTH, Z_DISTANCE}; //Finish top side.
}

final double MOVE_STEP = 5;
void keyPressed()
{ 
  //Use the arrow keys to move our focus point (where we are standing)
  //Remember that the origin is at the top-left, increasing downards and to the right:
  switch(keyCode) {
   case LEFT:
    focus_point[0] -= MOVE_STEP;
    break;
   case RIGHT:
     focus_point[0] += MOVE_STEP;
     break;
   case UP:
     focus_point[1] -= MOVE_STEP;
     break;
   case DOWN:
     focus_point[1] += MOVE_STEP;
     break;
   case 'q':
   case 'Q':
     camera_z += MOVE_STEP;
     break;
   case 'a':
   case 'A':
     camera_z -= MOVE_STEP;
     break;
   default:
     break;
  }
}

void draw() {
  background(255);

  float[] previous_point = null;
  println("debug: z=" + focus_point[2]);
  
  for (float[] vertex : vertices) {
    
    //Calculate the length of the straight line from the vertex to the focus point,
    //using pythagoras' theorem (a^2 + b^2 = c^2) extended to n dimensions:
    float real_focus_z = camera_z - focus_point[2];
    float[] real_focus = new float[DIMENSIONS];
    real_focus[0] = focus_point[0];
    real_focus[1] = focus_point[1];
    real_focus[2] = real_focus_z;
    
    final float vertex_to_focus_length = calc_side_length(vertex, real_focus);
  
    //Calculate the ratio of the z from the focus-point-to-camera to focus-point-to-vertex:
    //TODO: Avoid division by zero:
    final float ratio_z = (real_focus_z - camera_z) /
      (vertex[DIMENSION_CAMERA_PLANE - 1] - real_focus_z);
      
    final float screen_intersection_to_focus_length = vertex_to_focus_length * ratio_z;
     
    final float vertex_x = vertex[0];
    final float focus_x = focus_point[0];
    final float camera_x = (vertex_x - focus_x) * ratio_z;
     
    final float vertex_y = vertex[1];
    final float focus_y = focus_point[1];
    final float camera_y = (vertex_y - focus_y) * ratio_z;
     
    if (previous_point != null) {
      line(previous_point[0], previous_point[1],
        camera_x, camera_y);
    }
  
    previous_point = new float[] {camera_x, camera_y};
  }
}

/**
 * Calculate the length of the straight line from vertex a to vertex b
 * using pythagorus' theorem (a^2 + b^2 = c^2) extended to n dimensions.
 **/
float calc_side_length(final float[] a, final float[] b) {
  float product_of_squares = 0;
  for (int i = 0; i < DIMENSIONS; ++i) {
    final float length = a[i] - b[i];
    product_of_squares += pow(length, 2);
  }
  
  return sqrt(product_of_squares);
}





