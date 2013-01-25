/********************************************************
 *       Name:    Francis Sowani                        *
 *       Prof:    Daniel Shiffman                       *
 *       Course:  J-Term 2013 - Nature of Code          *
 *       Site:    New York University, New York         *
 ********************************************************/

class SuperAnt {
  final int DUP    = 0;
  final int DRIGHT = 1;
  final int DDOWN  = 2;
  final int DLEFT  = 3;
  final int MAZE_UNIT = 30;

  final char IS_WALL = 'o';
  final char IS_PATH = '-';
  final char IS_FOOD = 'f';
  final char IS_WOOD = 'x';
  final char IS_DOOR = 'd';

  final char IS_NOT_VISITED = 'n';
  final char IS_VISITED     = 'v';
  final char IS_MARKED      = 'm';

  PImage[] image; // four images used to display the superant
  PVector curPos; // current position of the superant
  char[][] map;
  int [][] visits;
  int curDir;  // current direction of the superant
  int nextDir;  // next desired direction of the superant
  ArrayList<PVector> foodLocations; // stores the locations where the user drops the food

  /*  Constructor  */
  SuperAnt(PVector initPos, String imageFile) {
    curDir = DRIGHT;
    curPos = initPos;
    image = new PImage[4]; 
    image[DUP] = loadImage(imageFile + "-up.png");
    image[DRIGHT] = loadImage(imageFile + "-right.png");
    image[DDOWN] = loadImage(imageFile + "-down.png");
    image[DLEFT] = loadImage(imageFile + "-left.png");

    foodLocations = new ArrayList<PVector>();
  }

  /*  Returns the current location of the ant  */
  PVector getCurrentPosition() {
    return curPos;
  }
  /*  Displays the ant at its current location in the maze */
  void display(PVector mazePos) {
    // println(curPos.x + ", " + curPos.y);
    imageMode(CENTER);
    image(image[curDir], MAZE_UNIT*(curPos.y+1)+mazePos.y, MAZE_UNIT*(curPos.x+1)+mazePos.x);
  }

  /*  Clears all the steps made by the ant and reloads the maze  */
  void clear() {
    for ( int K=0; K<visits.length; K++) {
      for (int L=0; L<visits[0].length; L++) {
        visits[K][L] = 0;
      }
    }
  }

  /*  Erases the visited location  */
  void informErased(PVector loc) {
    if ( loc != null) {
      visits[int(loc.x)][int(loc.y)] = 0;
    }
  }

  /*  Mark where the door is placed   */
  void informDoorPosition(PVector loc) {
    if ( loc != null) {
      map[int(loc.x)][int(loc.y)] = IS_DOOR;
    }
  }

  /*  Sets the map of the maze in which the ant is placed  */
  void setMap(String[] m ) {
    map = new char[m.length][m[0].length()];
    visits = new int[m.length][m[0].length()];
    //println("Map: " + map.length + " - " + map[0].length);

    for (int K=0; K<m.length; K++) {
      for (int L=0; L<m[0].length(); L++) {
        map[K][L] = m[K].charAt(L);
        visits[K][L] = 0;
      }
    }
  }

  /*  Adds a food location dropped by the user into the maze  */
  void feed(PVector foodLocation) {
    if ( foodLocation != null) {
      foodLocations.add(foodLocation);
    }
  }

  /*  Clears the path created from the explosion of the bomb dropped by the user  */
  void clearWood(PVector loc) {
    if ( loc != null) {
      map[int(loc.x)][int(loc.y)] = IS_PATH;
    }
  }

  /*  Places the ant at a particular position  */
  void placeAt(PVector loc) {
    curPos = loc;
  }

  /*  Calculates and makes the ant move to its next location if available  */
  boolean move() {
    /*
    if ( foodLocations.size()>0) { // seek food locations if available
      TODO: if the food is placed in the maze
     }
     else { // just make a random step
     // 
     */
    ArrayList<Integer> dirs = new ArrayList<Integer>();  // possible directions
    if (curPos.y > 0) { // check if possible to go left
      if (map[int(curPos.x)][int(curPos.y)-1] == IS_PATH || map[int(curPos.x)][int(curPos.y)-1] == IS_DOOR ) {
        dirs.add(DLEFT);
      }
    }
    if (curPos.y < map[0].length-1) { // check if possible to go right
      if (map[int(curPos.x)][int(curPos.y)+1] == IS_PATH || map[int(curPos.x)][int(curPos.y)+1] == IS_DOOR) {
        dirs.add(DRIGHT);
      }
    }
    if (curPos.x > 0) { // check if possible to go up
      if (map[int(curPos.x)-1][int(curPos.y)] == IS_PATH || map[int(curPos.x)-1][int(curPos.y)] == IS_DOOR) {
        dirs.add(DUP);
      }
    }
    if (curPos.x <map.length-1) { // check if possible to go down
      if (map[int(curPos.x)+1][int(curPos.y)] == IS_PATH || map[int(curPos.x)+1][int(curPos.y)] == IS_DOOR) {
        dirs.add(DDOWN);
      }
    }
    if (dirs.size()>0) {
      // Sort possible directions in increasing order of past visits
      for (int K=0; K<dirs.size()-1; K++) {
        for (int L=K+1; L<dirs.size(); L++) {
          if (getVisitCount(dirs.get(K)) > getVisitCount(dirs.get(L)) ) {
            int temp = dirs.get(K);
            dirs.set(K, dirs.get(L));
            dirs.set(L, temp);
          }
        }
      }
      if (getVisitCount(dirs.get(0)) < 2) {
        takeStep(dirs.get(0));
        if (visits[int(curPos.x)][int(curPos.y)] < 2) visits[int(curPos.x)][int(curPos.y)] += 1;
        return true;
      }

      //  }
    }

    return false;
  }

  /*  Returns the visited count of a location next to the current location */
  private int getVisitCount(int dir) {
    switch(dir) {
    case DLEFT:
      return visits[int(curPos.x)][int(curPos.y)-1];
    case DRIGHT:
      return visits[int(curPos.x)][int(curPos.y)+1];
    case DUP:
      return visits[int(curPos.x)-1][int(curPos.y)];
    case DDOWN:
      return visits[int(curPos.x)+1][int(curPos.y)];
    default:
      return 3;
    }
  }

  /*  Calculates the next ant's location when the food is in the maze  */
  private void computeNextDirection() {
    // Calculate average position
    int totalX=0, totalY=0, aveX, aveY;
    for (PVector v : foodLocations) {
      totalX += v.x;
      totalY += v.y;
    }
    aveX = totalX / foodLocations.size();
    aveY = totalY / foodLocations.size();

    // TODO: complete the computation
  }

  /*  Makes the ant take a single step in the specified direction */
  public void takeStep( int dir) {
    switch(dir) {
    case DUP:
      {
        curPos.add(new PVector(-1, 0));
        break;
      }
    case DRIGHT:
      {
        curPos.add(new PVector(0, 1));
        break;
      }
    case DDOWN:
      {
        curPos.add(new PVector(1, 0));
        break;
      }
    case DLEFT:
      {
        curPos.add(new PVector(0, -1));
        break;
      }
    }
    curDir = dir;
  }
}

