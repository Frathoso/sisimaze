/********************************************************
 *       Name:    Francis Sowani                        *
 *       Prof:    Daniel Shiffman                       *
 *       Course:  J-Term 2013 - Nature of Code          *
 *       Site:    New York University, New York         *
 ********************************************************/

import gifAnimation.*;

final String  PROJECT_COURSE = "nature of code 2013";
final String  PROJECT_TITLE  = "sisimaze";
final PVector MAZE_POSITION  = new PVector(90, 100);
final PVector ICON_BRUSH_LOC = new PVector(350, 30);
final PVector ICON_BOMB_LOC  = new PVector(450, 30);
final PVector ICON_FOOD_LOC  = new PVector(575, 30);
final PVector ICON_SCORE_LOC = new PVector(700, 30);
final int     BOMB_MAX_FRAME = 15;
final float   FOOD_AWARD_TIME= 0.5;  // time in minutes for awarding a food to the player
final float   BOMB_AWARD_TIME= 0.3;  // time in minutes for awarding a bomb to the player
final float   BRUSH_AWARD_TIME=0.05; // time in minutes for awarding a brush point to the player
final float   SCORE_AWARD_TIME=0.04; // time in minutes for awarding a score point to the player
final int     ANT_DELAY_TIME = 60;   // time in frames for the ant to wait before moving
final int     FOOD           = 100;
final int     BOMB           = 200;
final int     BRUSH          = 300;
final int     STATE_STARTING = 0;
final int     STATE_PLAYING  = 1;
final int     STATE_OVER     = 2;
final int     FRAME_RATE     = 60;    // main game's loops per second
final int     SPLASH_TIME    = 13;    // time in seconds for splash screen

color backColor;   // game's background color
Maze  maze;        // 
SuperAnt ant;      // 
PImage iconMain, iconBrush, iconBomb, iconFood, iconScore; // stores game's icon images
PImage mazeFood, mazeBomb, mazeBrush, tipsBoard;  // stores game's maze images
PImage splashBack; // background image in the splash/welcome screen
Gif bomb;          // frames for the dropped bomb animation
PFont font;        // 
int foodLeft, bombsLeft, totalScore, brushLeft;  // keeps track of the games statistics
int itemPicked;    // holds the id of the most recent item picked by player: FOOD or BOMB
boolean hasPickedSomething; // indicates if the player is dragging food/bomb
PVector droppedBombLoc;     // stores the most recent location of the dropped bomb
int gameState;     // one of three states of the game: STARTING, PLAYING, OVER
boolean isGameWon; // true if the player wins the game and false otherwise


/*  Initialize the game   */
void setup() {

  // Screen parameters
  backColor = color(0);
  size(800, 700);
  background(backColor);
  frameRate(FRAME_RATE);
  smooth();

  maze = new Maze("maze_easy.data", "wood.png", "door.jpg", "path.jpg", "path_once.jpg", 
  "path_twice.jpg", "wall.png", "path_food.png");

  ant = new SuperAnt(new PVector(int(random(0, 18)), int(random(0, 18))), "ant");
  ant.setMap(maze.getMap());

  // Loading the project font and icons
  loadIcons();
  font = createFont("finger_paint.ttf", 30);

  bomb = new Gif(this, "explosion.gif");

  gameState = STATE_STARTING;
}

/*  Game's main loop  */
void draw() {
  // Clear screen
  background(backColor);

  switch(gameState) {
  case STATE_STARTING:
    startGame();
    break;
  case STATE_PLAYING:
    playGame();
    break;
  case STATE_OVER:
    finishGame();
    break;
  default:
    exit();
  }

  //saveFrame("output/frames####.png");
}

/*  Brings the game to an initial state for a new play  */
void initializeGame() {
  // Initializing global variables
  brushLeft = 10;
  bombsLeft = 30;
  foodLeft = 3;
  totalScore = 0;
  hasPickedSomething = false;
  isGameWon = false;
  ant.placeAt(new PVector(int(random(0, 18)), int(random(0, 18))));

  maze = new Maze("maze_easy.data", "wood.png", "door.jpg", "path.jpg", "path_once.jpg", 
  "path_twice.jpg", "wall.png", "path_food.png");

  ant.clear();
  maze.clear();
  PVector doorPos = maze.placeDoor();
  ant.informDoorPosition(doorPos);
}


/*  Displays the splash/welcome screen when the game starts (i.e game STARTING state)   */
int dots = 0, sizeTitle = 1, sizeCourse, scale, pos = 300, separation=0;
boolean displayLoading = false;
void startGame() {
  image(splashBack, width/2, height/2);

  if (frameCount % 3 == 0) {   
    if (frameCount < 200) sizeTitle++;
    if (frameCount < 150) sizeCourse++;
    if (frameCount < 300) pos -= 2;
    if (frameCount % 6 == 0 && frameCount < 500) separation++;
  }

  stroke(255);
  strokeWeight(2);
  line(width/2, 0, width/2, height/2-pos);
  imageMode(CENTER);
  textAlign(CENTER);
  fill(240, 119, 120);
  textFont(font, sizeTitle);
  text(PROJECT_TITLE, width/2, height/2+separation);
  textFont(font, sizeCourse);
  fill(240, 119, 70);
  text(PROJECT_COURSE, width/2, height/2);
  image(iconMain, width/2, height/2 - pos);

  if (frameCount % 30 == 0) {
    dots = (dots++) % 4 + 1;
  }

  fill(0);
  textFont(font, 17);
  String dot = "";
  for (int K=0; K<dots; K++) dot += ".";
  textAlign(LEFT);
  text("Loading"+dot, width/2-50, height-100);

  if (frameCount % (SPLASH_TIME*FRAME_RATE) == 0) {
    initializeGame();
    gameState = STATE_PLAYING;
  }
}

/*  Displays the main game screen when the user plays ( i.e. game in PLAYING state)   */
void playGame() {
  // Display game's main objects
  maze.display(MAZE_POSITION);
  ant.display(MAZE_POSITION);

  showProjectTitleBoard();
  showGameStatistics();

  // Display the picked item if available
  if (hasPickedSomething) {
    if (itemPicked == FOOD) {
      image(mazeFood, mouseX, mouseY);
    }
    else if (itemPicked == BOMB) {
      image(mazeBomb, mouseX, mouseY);
    } 
    else if (itemPicked == BRUSH) {
      image(mazeBrush, mouseX, mouseY);
    }
  }

  // Display the exploding bomb if available
  if (bomb.isPlaying()) {
    bombLocation();
    if (bomb.currentFrame() > BOMB_MAX_FRAME) {
      bomb.stop();
      PVector bombLoc = maze.destroy(droppedBombLoc);
      ant.clearWood(bombLoc);
    }
  }

  // Move the ant if it's time to do so and it can do so
  if (frameCount % ANT_DELAY_TIME == 0) {
    if (ant.move() == false) {
      gameState = STATE_OVER;
    }
    else {
      maze.markAsStepped(ant.getCurrentPosition());

      if ( maze.isAtTheDoor(ant.getCurrentPosition())) {
        isGameWon = true;
        gameState = STATE_OVER;
      }
    }
  }

  // Award the player some points for keeping the ant alive
  if (frameCount % int(SCORE_AWARD_TIME*FRAME_RATE*60) == 0 ) {
    totalScore++;
  }

  // Increse the food count
  if (frameCount % (FOOD_AWARD_TIME*FRAME_RATE*60) == 0 ) {
    foodLeft++;
  }

  // Increse the bombs count
  if (frameCount % (BOMB_AWARD_TIME*FRAME_RATE*60) == 0 ) {
    bombsLeft++;
  }

  // Increse the brush points count
  if (frameCount % (BRUSH_AWARD_TIME*FRAME_RATE*60) == 0 ) {
    brushLeft++;
  }
}

/*  Displays the last screen after the game is over with a win or a loss ( i.e. game in OVER state )  */
void finishGame() {
  imageMode(CENTER);
  image(splashBack, width/2, height/2);

  if (isGameWon) {
    textAlign(CENTER);
    fill(240, 19, 20);
    textFont(font, 40);
    text("GAME OVER", width/2, height/2-150);

    fill(97, 173, 65);
    text("Congratulations!! You Won!!!", width/2, height/2-50);

    fill(150, 19, 20);
    text("You scored: " + totalScore, width/2, height/2+50);

    fill(240, 19, 20);
    textFont(font, 20);
    text("The ant is now reunited with its colony, thanks to you!!!", width/2, height/2+150);
  }
  else {
    textAlign(CENTER);
    fill(240, 19, 20);
    textFont(font, 40);
    text("GAME OVER", width/2, height/2-150);
    text("You lost, try again", width/2, height/2-50);

    fill(150, 19, 20);
    text("You scored: " + totalScore, width/2, height/2+50);

    fill(240, 19, 20);
    textFont(font, 20);
    text("It's sad you could not help the ant!!!", width/2, height/2+150);
  }

  fill(0);
  textFont(font, 17);
  String dot = "";
  for (int K=0; K<dots; K++) dot += ".";
  text("Press <ENTER> to play again or any other key to quit!", width/2, height-100);
}

/*  Handles "mouse pressed" events  */
void mousePressed() {
  if (isMouseOnBomb() && bombsLeft > 0) {
    hasPickedSomething = true;
    itemPicked = BOMB;
    bombsLeft--;
  }
  else if (isMouseOnFood() && foodLeft > 0) {
    hasPickedSomething = true;
    itemPicked = FOOD;
    foodLeft--;
  }
  else if (isMouseOnBrush() && brushLeft >0) {
    hasPickedSomething = true;
    itemPicked = BRUSH;
  }
}

/*  Handles "mouse released" events  */
void mouseReleased() {
  if (hasPickedSomething) {
    if ( itemPicked == FOOD ) {
      PVector mazeLoc = maze.feed(new PVector(mouseX, mouseY));
      ant.feed(mazeLoc);
    }
    else if ( itemPicked == BOMB) {
      droppedBombLoc = new PVector(mouseX, mouseY);
      bomb.stop();
      bomb.play();
    }
    hasPickedSomething = false;
  }
}

/*  Handles "mouse dragging" events  */
void mouseDragged() {
  // Checks if the player has selected brush and held down space for erasing a path
  if (hasPickedSomething && itemPicked == BRUSH && brushLeft > 0) {
    if ( keyPressed && key == ' ' ) {
      if (maze.isVisited(new PVector(mouseX, mouseY))) {
        PVector erasedLoc = maze.erasePath(new PVector(mouseX, mouseY));
        ant.informErased(erasedLoc);
        brushLeft--;
      }
    }
  }
}

/*  Handles "key pressed" events  */
void keyPressed() {
  if (gameState == STATE_OVER && (key == ENTER || key == RETURN)) {
    initializeGame();
    gameState = STATE_PLAYING;
  }
}

/*  Checks if the mouse can pick a bomb  */
boolean isMouseOnBomb() {
  return dist(ICON_BOMB_LOC.x, ICON_BOMB_LOC.y, mouseX, mouseY) < 15 ? true : false;
}

/*  Checks if the mouse can pick food  */
boolean isMouseOnFood() {
  return dist(ICON_FOOD_LOC.x, ICON_FOOD_LOC.y, mouseX, mouseY) < 15 ? true : false;
}

/*  Checks if the mouse can pick food  */
boolean isMouseOnBrush() {
  return dist(ICON_BRUSH_LOC.x, ICON_BRUSH_LOC.y, mouseX, mouseY) < 15 ? true : false;
}

/*  Displays a bomb at the most recent dropped location  */
void bombLocation() {
  image(bomb, droppedBombLoc.x, droppedBombLoc.y);
}

/*  Displays the state/statistics of the ongoing game in PLAYING state  */
void showGameStatistics() {
  imageMode(CENTER);
  textFont(font, 25);
  textAlign(CENTER);
  image(iconBrush, ICON_BRUSH_LOC.x, ICON_BRUSH_LOC.y);
  fill(240, 119, 70);
  text(brushLeft, ICON_BRUSH_LOC.x, ICON_BRUSH_LOC.y+50);

  image(iconBomb, ICON_BOMB_LOC.x, ICON_BOMB_LOC.y);
  fill(240, 119, 70);
  text(bombsLeft, ICON_BOMB_LOC.x, ICON_BOMB_LOC.y+50);

  image(iconFood, ICON_FOOD_LOC.x, ICON_FOOD_LOC.y );
  fill(204, 204, 239);
  text(foodLeft, ICON_FOOD_LOC.x, ICON_FOOD_LOC.y+50);

  image(iconScore, ICON_SCORE_LOC.x, ICON_SCORE_LOC.y);
  fill(18, 243, 18);
  text(totalScore, ICON_SCORE_LOC.x-5, ICON_SCORE_LOC.y+50);
}

/*  Loads from memory all the images used as icons in the game  */
void loadIcons() {
  print("Loading icons ... ");
  iconMain  = loadImage("ant.png");
  iconBomb  = loadImage("bomb.png");
  iconBrush = loadImage("brush.png");
  iconFood  = loadImage("food.png");
  iconScore = loadImage("score.png");
  mazeBrush = loadImage("maze_brush.png");
  mazeFood  = loadImage("maze_food.png");
  mazeBomb  = loadImage("maze_bomb.png");
  splashBack = loadImage("splash_back.png");
  tipsBoard = loadImage("tips_board.png");
  println("COMPLETED");
}

/*  Displays the game title in the PLAYING state  */
int changeY = 0, dy=1;
void showProjectTitleBoard() {
  // Title
  fill(204, 204, 239);
  textFont(font, 30);
  textAlign(LEFT);
  text("SisiMaze", 90, 70);

  // Ant
  imageMode(CENTER);
  int antXPos = 55;
  image(iconMain, antXPos, 70);

  // Board
  stroke(200);
  strokeWeight(2);
  line(antXPos, 70, antXPos, 170);
  image(tipsBoard, antXPos, 280);
  image(tipsBoard, width-antXPos, 280);

  // Instructions for left board
  textFont(font, 15);
  textAlign(CENTER);
  fill(int(map(changeY, -10, 10, 0, 180)));
  text("Drag food", antXPos, 210+changeY);
  text("into the path", antXPos, 230+changeY);
  text("to attract", antXPos, 250+changeY);
  text("the ant!!!", antXPos, 270+changeY);
  text("Drag bombs", antXPos, 300+changeY);
  text("to wooden", antXPos, 320+changeY);
  text("paths to", antXPos, 340+changeY);
  text("create new", antXPos, 360+changeY);
  text("paths!!", antXPos, 380+changeY);

  // Instructions for right board
  text("Select brush", width-antXPos, 210+changeY);
  text("and drag it", width-antXPos, 230+changeY);
  text("over visited", width-antXPos, 250+changeY);
  text("path, while", width-antXPos, 270+changeY);
  text("holding down", width-antXPos, 300+changeY);
  text("SPACE bar", width-antXPos, 320+changeY);
  text("to delete", width-antXPos, 340+changeY);
  text("the ant", width-antXPos, 360+changeY);
  text("marks!!", width-antXPos, 380+changeY);

  if (frameCount % 5 == 0) {
    changeY += dy;
    if (changeY < -10 || changeY > 10) dy *= -1;
  }
}

