/********************************************************
 *       Name:    Francis Sowani                        *
 *       Prof:    Daniel Shiffman                       *
 *       Course:  J-Term 2013 - Nature of Code          *
 *       Site:    New York University, New York         *
 ********************************************************/
 
class Maze {
  final int MAZE_UNIT = 30;
  final int WOOD_COUNT = 10;
  final char IS_WALL = 'o';
  final char IS_PATH = '-';
  final char IS_FOOD = 'f';
  final char IS_WOOD = 'x';
  final char IS_DOOR = 'd';
  final char IS_HIDDEN_DOOR = 'X';

  String[] map;
  int[][]  antVisits;
  PImage   wall;  
  PImage   path, pathVisitedOnce, pathVisitedTwice;  
  PImage   wood;
  PImage   food;
  PImage   door;
  PVector  mazeLocation;

  /* Constructor  */
  Maze(String mazeFile, String wallFile, String doorFile, String pathFile, 
  String pathOnceFile, String pathTwiceFile, String woodFile, String foodFile) {
    map  = importMaze(mazeFile);
    antVisits = new int[map.length][map[0].length()];
    wall = importImage(wallFile);
    door = importImage(doorFile);
    path = importImage(pathFile);
    pathVisitedOnce  = importImage(pathOnceFile);
    pathVisitedTwice = importImage(pathTwiceFile);
    wood = importImage(woodFile);
    food = importImage(foodFile);
    mazeLocation = null;
  }

  /* Returns the map used to build the maze  */
  String[] getMap() {
    return map;
  }

  /* Display the maze from the map */
  void display(PVector startPos) {
    if ( mazeLocation == null) {
      mazeLocation = startPos;
    }
    if ( map != null) {
      PVector pos;
      for (int K=0; K<map.length; K++) {
        for (int L=0; L<map[0].length(); L++) {
          if (map[K].charAt(L) == IS_WALL) {
            pos = new PVector(MAZE_UNIT*(K+1), MAZE_UNIT*(L+1));
            pos.add(startPos);
            drawWall(pos);
          }
          else if (map[K].charAt(L)== IS_PATH) {
            pos = new PVector(MAZE_UNIT*(K+1), MAZE_UNIT*(L+1));
            pos.add(startPos);
            drawPath(pos);
          }
          else if (map[K].charAt(L)== IS_WOOD || map[K].charAt(L)== IS_HIDDEN_DOOR) {
            pos = new PVector(MAZE_UNIT*(K+1), MAZE_UNIT*(L+1));
            pos.add(startPos);
            drawWood(pos);
          }
          else if (map[K].charAt(L)== IS_FOOD) {
            pos = new PVector(MAZE_UNIT*(K+1), MAZE_UNIT*(L+1));
            pos.add(startPos);
            drawFood(pos);
          } 
          else if (map[K].charAt(L)== IS_DOOR) {
            pos = new PVector(MAZE_UNIT*(K+1), MAZE_UNIT*(L+1));
            pos.add(startPos);
            drawDoor(pos);
          }
        }
      }
    }
  }

  /* Load a maze from a file  */
  String[] importMaze(String fileName) {
    try {
      print("Loading maze from \""+ fileName + "\" ... ");
      println("COMPLETED");
      return loadStrings(fileName);
    }
    catch(Exception e) {
      println("FAILED");
      return null;
    }
  }

  /*  Clears all the steps made by the ant and reloads the maze  */
  void clear() {
    for ( int K=0; K<antVisits.length; K++) {
      for (int L=0; L<antVisits[0].length; L++) {
        antVisits[K][L] = 0;
      }
    }
  }

  /* Load an image from a file  */
  PImage importImage(String fileName) {
    try {
      print("Loading image from \""+ fileName + "\" ... ");
      PImage image = loadImage(fileName);
      println("COMPLETED");
      return image;
    }
    catch(Exception e) {
      println("FAILED");
      return null;
    }
  }

  /* Draws a wall segment of the maze */
  void drawWall(PVector pos) {
    imageMode(CENTER);
    image(wall, pos.y, pos.x);
  }

  /* Draws a door in the maze */
  void drawDoor(PVector pos) {
    imageMode(CENTER);
    image(door, pos.y, pos.x);
  }

  /* Draws a path segment of the maze  */
  void drawPath(PVector pos) {
    imageMode(CENTER);
    switch(antVisits[int((pos.x -mazeLocation.x)/MAZE_UNIT)-1][int((pos.y-mazeLocation.y)/MAZE_UNIT)-1]) {
    case 1:
      image(pathVisitedOnce, pos.y, pos.x);
      break;
    case 2:
      image(pathVisitedTwice, pos.y, pos.x);
      break;
    default:
      image(path, pos.y, pos.x);
    }
  }

  /* Draws a wood segment of the maze  */
  void drawWood(PVector pos) {
    imageMode(CENTER);
    image(wood, pos.y, pos.x);
  }
  /* Draws a path segment with food  */
  void drawFood(PVector pos) {
    imageMode(CENTER);
    image(food, pos.y, pos.x);
  }

  /*  Checks if an ant can still visit a location  */
  boolean canVisit(PVector loc) {
    int col = int(( loc.x - mazeLocation.x)/MAZE_UNIT)-1;
    int row = int((loc.y - mazeLocation.y)/MAZE_UNIT);

    if ( row >= 0 && row < map.length && col >= 0 && col < map[0].length()) {
      if ( antVisits[row][col] < 2 ) return true;
    }
    return false;
  }

  /*  Checks if a location has been visited  */
  boolean isVisited(PVector loc) {
    int col = int(( loc.x - mazeLocation.x)/MAZE_UNIT)-1;
    int row = int((loc.y - mazeLocation.y)/MAZE_UNIT);

    if ( row >= 0 && row < map.length && col >= 0 && col < map[0].length()) {
      if ( antVisits[row][col] > 0 ) return true;
    }
    return false;
  }

  /* Marks the spot where the ant steps  */
  void markAsStepped(PVector loc) {
    int col = int(loc.y);
    int row = int(loc.x);

    if ( row >= 0 && row < map.length && col >= 0 && col < map[0].length()) {
      if ( antVisits[row][col] < 2 ) antVisits[row][col] += 1;
    }
  }

  /* Checks if the door is at the given location  */
  boolean isAtTheDoor(PVector loc) {
    return map[int(loc.x)].charAt(int(loc.y)) == IS_DOOR ;
  }

  /* Chooses one wooden spot to hide the door out of the maze  */
  PVector placeDoor() {
    //
    int doorPos = int(random(0, WOOD_COUNT)), index = 0;

    for (int K=0; K<map.length; K++) {
      for (int L=0; L<map[0].length(); L++) {
        if (map[K].charAt(L) == IS_WOOD) {
          if (index == doorPos) {
            if (L == 0 )
              map[K] = IS_HIDDEN_DOOR+map[K].substring(L+1);
            else
              map[K] = map[L].substring(0, L)+IS_HIDDEN_DOOR+map[K].substring(L+1);
            return new PVector(K, L);
          }
          else {
            index++;
          }
        }
      }
    }
    return null;
  }

  /* Erases the visited position if it is a visited path */
  PVector erasePath(PVector loc) {
    int col = int(( loc.x - mazeLocation.x)/MAZE_UNIT)-1;
    int row = int((loc.y - mazeLocation.y)/MAZE_UNIT);
    //(row + " " + col);
    if ( row >= 0 && row < map.length && col >= 0 && col < map[0].length()) {
      //(map[row].charAt(col));
      antVisits[row][col] = 0;
      return new PVector(row, col);
    }
    return null;
  }

  /*  Clears the path if the position has a wood  */
  PVector destroy(PVector loc) {
    int col = int(( loc.x - mazeLocation.x)/MAZE_UNIT)-1;
    int row = int((loc.y - mazeLocation.y)/MAZE_UNIT);
    //(row + " " + col);
    if ( row >= 0 && row < map.length && col >= 0 && col < map[0].length()) {
      //(map[row].charAt(col));
      if (map[row].charAt(col) == IS_WOOD) {
        if (col == 0 )
          map[row] = IS_PATH+map[row].substring(col+1);
        else
          map[row] = map[row].substring(0, col)+IS_PATH+map[row].substring(col+1);
      }
      else if (map[row].charAt(col) == IS_HIDDEN_DOOR) {
        if (col == 0 )
          map[row] = IS_DOOR+map[row].substring(col+1);
        else
          map[row] = map[row].substring(0, col)+IS_DOOR+map[row].substring(col+1);
      }
      return new PVector(row, col);
    }
    return null;
  }

  /* Places food at the given location */
  PVector feed(PVector loc) {
    int col = int(( loc.x - mazeLocation.x)/MAZE_UNIT)-1;
    int row = int((loc.y - mazeLocation.y)/MAZE_UNIT);
    //(row + " " + col);
    if ( row >= 0 && row < map.length && col >= 0 && col < map[0].length()) {
      //(map[row].charAt(col));
      if (map[row].charAt(col) == IS_PATH) {
        if (col == 0 ) {
          map[row] = IS_FOOD+map[row].substring(col+1);
        }
        else {
          map[row] = map[row].substring(0, col)+IS_FOOD+map[row].substring(col+1);
        }
        return new PVector(row, col);
      }
    }
    return null;
  }
}

