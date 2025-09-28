' DRAGONFEAR - MMBasic Version
' Original BASIC game (Duke Of Dragonfear)
' created by Time Hartnell.
' Converted to MMBasic

MODE 2
FONT 4

COLOR RGB(GREEN)

' cave map
DIM caveMap(100)

' amulet probe offsets
DIM probeOffset(8)

' player stats
DIM playerGold
DIM playerPos
DIM charismaUsed
DIM arrows
DIM treasureValue
DIM delayPause

' main loop control
DIM gameState
delayPause = 1000

' intro and setup
GOSUB Intro
CLS
PRINT
PRINT
PRINT

GOSUB ShowMap
PAUSE delayPause*2

' ============================
' Main game loop
' ============================
MainLoop:
eventRoll = INT(RND * 7)
IF eventRoll = 0 AND playerPos <> 55 THEN 
  GOSUB ShowMap
END IF

CLS
PRINT
PRINT
PRINT playerName$; ", you are in cave "; 
PRINT STR$(playerPos); "."

' show gold carried
goldStr$ = STR$(playerGold)
IF playerGold >= 0 THEN 
  goldStr$ = RIGHT$(goldStr$, LEN(goldStr$) - 1)
END IF
IF playerGold > 0 THEN 
  PRINT "You are carrying $"; goldStr$; 
  PRINT " worth of gold."
END IF

probeIndex = 1
GOSUB Amulet

PRINT
PRINT "You have"; 25 - charismaUsed; " charisma left."
PRINT
PRINT "What do you want to do?"
PRINT "N,S,E,W - move"
PRINT "F - fight, Q - quit"
PRINT

INPUT "Your move"; action$
action$ = UCASE$(action$)

validAction = 0
IF action$="N" OR action$="S" OR action$="E" OR action$="W" OR action$="F" OR action$="Q" THEN 
  validAction = 1
END IF
IF validAction=0 THEN GOTO InvalidMove

' check blocked movement
IF action$ = "N" AND caveMap(playerPos - 10) = 88 THEN 
  PRINT "You cannot move that way!"
  GOTO MainLoop
END IF
IF action$ = "S" AND caveMap(playerPos + 10) = 88 THEN 
  PRINT "You cannot move that way!"
  GOTO MainLoop
END IF
IF action$ = "E" AND caveMap(playerPos + 1) = 88 THEN 
  PRINT "You cannot move that way!"
  GOTO MainLoop
END IF
IF action$ = "W" AND caveMap(playerPos - 1) = 88 THEN 
  PRINT "You cannot move that way!"
  GOTO MainLoop
END IF

IF action$ = "Q" THEN 
  gameState = 9
  GOTO QuitGame
END IF

' clear current cave
caveMap(playerPos) = 46

' move or fight
IF action$ = "N" THEN playerPos = playerPos - 10
IF action$ = "S" THEN playerPos = playerPos + 10
IF action$ = "E" THEN playerPos = playerPos + 1
IF action$ = "W" THEN playerPos = playerPos - 1
IF action$ = "F" THEN GOSUB ShootDragon

' check encounters
IF caveMap(playerPos) = 63 THEN GOSUB MagicCave
IF caveMap(playerPos) = 68 THEN GOSUB DragonLair
IF caveMap(playerPos) = 81 THEN GOSUB Quicksand
IF caveMap(playerPos) = 36 THEN GOSUB Treasure

' charisma drains each move
charismaUsed = charismaUsed + 1
IF charismaUsed = 25 THEN 
  gameState = 9
  GOTO GameOver
END IF

PAUSE delayPause
GOTO MainLoop

' ============================
InvalidMove:
PRINT "Invalid. Use N,S,E,W,F,Q"
GOTO MainLoop

' ============================
MagicCave:
PRINT
PRINT playerName$; ", you've stumbled into"
PRINT "a magic cave, whisked elsewhere..."
PAUSE delayPause
caveMap(playerPos) = 46
playerPos = INT(RND * 76) + 12
IF caveMap(playerPos) = 88 THEN GOTO MagicCave
RETURN

' ============================
DragonLair:
PRINT "You have wandered into"
PRINT "a dragon's lair..."
PAUSE delayPause

dragonRoll = RND
IF dragonRoll < .2 THEN
  PRINT "It has flown away!"
  RETURN
END IF

PRINT "It awakens... and it sees you!"
PAUSE delayPause
dragonRoll = RND
IF dragonRoll > .8499999 THEN
  PRINT "But it has eaten recently."
  PRINT "It goes back to sleep."
  RETURN
END IF

PRINT "And now it attacks..."
PAUSE delayPause*2

dragonRoll = RND
IF dragonRoll > .95 THEN
  PRINT "You fight back... and win."
  RETURN
END IF

PRINT "Goodbye, "; playerName$; "."
PAUSE delayPause
gameState = 9
GOTO GameOver

' ============================
Quicksand:
FOR row = 1 TO 12
  FOR indent = 1 TO row
    PRINT " ";
  NEXT
  PRINT "Horrors... quicksand!"
  PAUSE delayPause/2
NEXT
gameState = 9
charismaUsed = 0
GOTO GameOver

' ============================
Treasure:
treasureValue = INT(RND * 100) + 100
FOR row = 1 TO 12
  FOR indent = 1 TO row
    PRINT " ";
  NEXT
  PRINT "Treasure!!!"
  PAUSE delayPause/2
NEXT

PAUSE delayPause
treasureStr$ = STR$(treasureValue)
treasureStr$ = RIGHT$(treasureStr$, LEN(treasureStr$) - 1)
PRINT
PRINT "You've found dragon-gold worth $"; treasureStr$; "!"
playerGold = playerGold + treasureValue
RETURN

' ============================
Amulet:
scanTile = caveMap(playerPos + probeOffset(probeIndex))
IF scanTile <> 46 THEN GOTO AmuletFound
IF probeIndex < 8 THEN
  probeIndex = probeIndex + 1
  GOTO Amulet
END IF
IF scanTile = 46 THEN RETURN

AmuletFound:
PRINT "Your amulet signals nearby ";
IF scanTile = 88 THEN PRINT "wall."
IF scanTile = 63 THEN PRINT "magic cave."
IF scanTile = 68 THEN PRINT "dragon."
IF scanTile = 81 THEN PRINT "quicksand."
IF scanTile = 36 THEN PRINT "gold."
PAUSE delayPause
RETURN

' ============================
ShootDragon:
PRINT
arrows = arrows - 1
IF arrows = 0 THEN
  PRINT "You used up all arrows..."
  PAUSE delayPause
  RETURN
END IF

PRINT "You have"; arrows; " arrows left."
shotHit = 0

PRINT "Which direction (N,S,E,W)"
INPUT shootDir$
shootDir$ = UCASE$(shootDir$)

IF shootDir$ = "N" AND caveMap(playerPos - 10) = 68 THEN 
  shotHit = 1
  targetTile = playerPos - 10
END IF
IF shootDir$ = "S" AND caveMap(playerPos + 10) = 68 THEN 
  shotHit = 1
  targetTile = playerPos + 10
END IF
IF shootDir$ = "E" AND caveMap(playerPos + 1) = 68 THEN 
  shotHit = 1
  targetTile = playerPos + 1
END IF
IF shootDir$ = "W" AND caveMap(playerPos - 1) = 68 THEN 
  shotHit = 1
  targetTile = playerPos - 1
END IF

PRINT
IF shotHit = 0 THEN
  PRINT "No dragon there..."
  PRINT "You wasted an arrow."
  PAUSE delayPause
  RETURN
END IF

PRINT "Well done, "; playerName$; "!"
PRINT "You hit a dragon."
PAUSE delayPause

IF RND > .3 THEN GOTO WoundedDragon

PRINT "You killed it!"
caveMap(targetTile) = 46
bonusGold = INT(RND * 100) + 100
bonusGoldStr$ = STR$(bonusGold)
bonusGoldStr$ = RIGHT$(bonusGoldStr$, LEN(bonusGoldStr$) - 1)
PRINT
PRINT "You are rewarded with $"; bonusGold; "."
playerGold = playerGold + bonusGold
PAUSE delayPause
RETURN

' ============================
WoundedDragon:
PRINT "But you only wounded it..."
PAUSE delayPause
RETURN

' ============================
GameOver:
IF charismaUsed < 1 THEN
  PRINT "All your charisma is gone..."
  PAUSE delayPause
  GOTO FinalScore
END IF

' ============================
QuitGame:
PRINT "You have"; 25 - charismaUsed; " charisma left."

FinalScore:
goldStr$ = STR$(playerGold)
goldStr$ = RIGHT$(goldStr$, LEN(goldStr$) - 1)
IF playerGold > 0 THEN 
  PRINT "You amassed $"; goldStr$; " of gold."
END IF
PRINT
END

' ============================
ShowMap:
PRINT
caveMap(playerPos) = 72
FOR row = 1 TO 100
  IF RIGHT$(STR$(row - 1), 1) = "0" THEN 
    PRINT TAB(30);
  END IF
  mapChar$ = CHR$(caveMap(row))
  IF mapChar$ = "X" THEN
    PRINT CHR$(178); CHR$(178);
    GOTO NextMap
  END IF
  IF mapChar$ = "Q" THEN COLOR RGB(MAGENTA)
  IF mapChar$ = "D" THEN COLOR RGB(RED)
  IF mapChar$ = "$" THEN COLOR RGB(YELLOW)
  IF mapChar$ = "H" THEN COLOR RGB(CYAN)
  IF mapChar$ = "?" THEN COLOR RGB(PINK)
  PRINT mapChar$; " ";
  COLOR RGB(GREEN)
NextMap:
  IF 10 * INT(row / 10) = row THEN PRINT
NEXT
PAUSE delayPause
IF gameState = 9 THEN END
RETURN

' ============================
Intro:
CLS

PRINT
COLOR RGB(MAGENTA)
PRINT "   Welcome to Dragonfear!"
COLOR RGB(GREEN)
PRINT "   A game by Tim Hartnell"
PRINT
PRINT "Explore caves, seek treasure,"
PRINT "     and slay dragons."
PRINT
PRINT "         //      \"
PRINT "        // (    ) \"
PRINT "       //  |\^^/|  \"
PRINT "      //   (";
COLOR RGB(RED)
PRINT "@";
COLOR RGB(GREEN)
PRINT "::";
COLOR RGB(RED)
PRINT "@";
COLOR RGB(GREEN)
PRINT ")   \"
PRINT "     ((     \__/     ))"
PRINT "       \    (oo)    /"
PRINT "        \  / VV \  /"
PRINT "         \/      \/"
PRINT
PRINT "What is your name";
INPUT playerName$
CLS
PRINT
PRINT "All hail, "; playerName$; "!"
PRINT
PRINT "You start with 25 charisma."
PRINT "Each move costs 1 charisma."
PRINT
PRINT "The caves are dark but sometimes"
PRINT "you will glimpse your map. The map"
PRINT "legend is:";
COLOR RGB(YELLOW)
PRINT " H(you), $(treasure),"
PRINT "D(dragon), ?(magic cave), Q(quicksand)"
COLOR RGB(GREEN)
PRINT
PRINT "(Press any key)"
seedVal = 1

DO
    key$ = INKEY$
    seedVal = seedVal + 1
LOOP UNTIL key$ <> ""

RANDOMIZE seedVal
CLS
PRINT "Please stand by, "; playerName$; "..."
charismaUsed = 0
gameState = 0
scanTile = 0
playerGold = 0
arrows = 6

' build cave
FOR cell = 1 TO 100
  caveMap(cell) = 46
  IF cell < 12 OR cell > 90 THEN 
    caveMap(cell) = 88
  END IF
  IF 10 * INT(cell / 10) = cell THEN 
    caveMap(cell) = 88
  END IF
  IF 10 * INT(cell / 10) = cell - 1 THEN 
    caveMap(cell) = 88
  END IF
NEXT

' place hazards and treasure
FOR round = 1 TO 5
  RESTORE
  FOR i = 1 TO 5
    DO
        randCell = INT(RND * 76) + 12
    LOOP UNTIL caveMap(randCell) <> 88
    READ cellType
    caveMap(randCell) = cellType
  NEXT
NEXT
GOTO InitPointers

' ============================
InitPointers:
DATA 88,63,68,81,36
FOR i = 1 TO 8
  READ randCell
  probeOffset(i) = randCell
NEXT
DATA -11,-10,-9,-1,1,9,10,11
playerPos = 55
RETURN
