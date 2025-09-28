# Dragonfear

**Dragonfear** is a text-based adventure game written in MMBasic and Picomite BASIC. It is ported from Duke of Dragonfear, a fantasy game created by Tim Hartnell in his Giant Book Of Computer Games (1984).

Explore a dangerous cave system, find treasure, avoid traps, and defeat dragons with your bow.  

---

## How to Play

- You start with **25 charisma points**.  
  Each move costs **1 charisma**. When charisma runs out, the game ends.  

- You begin with **6 arrows**.  
  Use them wisely to slay dragons or you may end up defenseless.  

- On each turn you choose an action:
  - `N` – move North  
  - `S` – move South  
  - `E` – move East  
  - `W` – move West  
  - `F` – Fight: shoot an arrow in a direction  
  - `Q` – Quit game  

- On the cave map, which you occasionally glimpse, the following legend is used:
  - `H` – Hero (you)  
  - `$` – Treasure (worth 100–199 gold)  
  - `D` – Dragon (deadly unless killed with arrows)  
  - `M` – Magic cave (teleports you)  
  - `Q` – Quicksand (from which there is no escape)  

An **amulet** warns you if something dangerous is near.  

Your goal:  
Survive as long as possible, slay dragons, and collect gold before running out of charisma.  

---

## 🧩 How the Map Array Works

The cave is stored in a **1D array**:

`DIM caveMap(100)`

    Each element of caveMap() represents a tile in the 10×10 grid.

    Indexing is row-major order:

        caveMap(1) = top-left corner

        caveMap(10) = top-right corner

        caveMap(11) = start of second row

        … until caveMap(100) = bottom-right corner

Tile Encoding (ASCII codes)

    46 → . Empty cave

    88 → X Wall

    72 → H Hero (player position)

    36 → $ Treasure

    68 → D Dragon

    63 → M Magic cave

    81 → Q Quicksand

The ShowMap routine converts these codes into symbols and prints them row by row.
Movement

    North: playerPos - 10

    South: playerPos + 10

    East: playerPos + 1

    West: playerPos - 1

This works because each row is 10 cells wide.

## 🔮 Amulet Scanning Pattern

The amulet checks for nearby dangers or treasure.
It uses offsets around the hero's position:

DATA -11,-10,-9,-1,1,9,10,11

This means the amulet looks in all 8 directions around the player:

 -11   -10   -9
  -1    H    +1
  +9   +10  +11

Legend:

    H = Hero’s current cave (playerPos)

    Offsets = relative positions in caveMap()

So for example:

    playerPos - 10 = directly North

    playerPos + 1 = directly East

    playerPos + 10 = directly South

    playerPos - 1 = directly West

    Diagonals use ±9 and ±11

If any tile in those positions is not empty (46), the amulet gives a warning:

    Wall, Magic cave, Dragon, Quicksand, or Treasure nearby.

🗂️ Game Flow

    Intro Screen

        Welcomes the player.

        Shows map legend.

        Asks for player name.

    Game Loop

        Shows current cave.

        Displays charisma and gold.

        Uses amulet to scan nearby tiles.

        Waits for player input.

    Encounters

        M → Magic Cave teleport.

        D → Dragon fight (deadly).

        Q → Quicksand (game over).

        $ → Treasure (gain gold).

    Game End

        Charisma used up.

        Quicksand or dragon death.

        Player quits.

Final score = total gold.

## 🔧 Subroutines Overview

    Intro – Show intro text, legend, ask name, setup game.

    ShowMap – Render the 10×10 cave grid.

    Amulet – Detect nearby hazards or treasure.

    MagicCave – Teleport to a random cave.

    DragonLair – Handle dragon encounter.

    Quicksand – Quicksand animation, ends game.

    Treasure – Gain random treasure (100–199 gold).

    ShootDragon – Player shoots an arrow at a dragon.

    WoundedDragon – Show message if dragon survives.

    GameOver – End game, print final score.

    InitPointers – Setup amulet probe offsets.

## 🏆 Winning Condition

There is no single “win”.
The challenge is to survive and amass the highest gold total before you die or charisma runs out.
