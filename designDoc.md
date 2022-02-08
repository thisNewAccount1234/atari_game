# Game Design Document

## Game Concept

"Tank" style game where the player is player0 sprite, using missle0, who moves around the city, background color black due to it being night, and must navigate around various parts of the play field, which represent the buildings of the city.

The enemy, using player1 sprite, moves randomly and if it collides with a part of the play field that building will disapear.

The player must shoot the enemy to prevent it from destroying buildings, if all buildings are destroyed the game is over.  Also, if the enemy collides with the player the game is over.

The player will proceed to subsequent levels when the enemy is killed.  Subsequent levels have an enemy that moves faster, possibly copies of sprite1 (?)  The score board is used to capture either a) the level or b) player0 score is number of enemies killed and player1 score is number of buildings destroyed.

## Alternate Game Concepts

List alternate concepts here.

## Ideas, Questions, To Do

Learn how to draw and animate any sprite, start with fire

Learn how to position sprite at any x, y position

Learn to control/move sprite with joystick

Draw playfield of city

Draw player sprite

Animate player sprite

Draw enemy sprite

Animate enemy sprite

Detect collision of player with playfield (do you have to prevent player from moving into it? or will it do that automatically?)

Detect collision of enemy with playfield, erase that part of the playfield (this will cause its mirrored part to also disappear, how to fix?)

Detect collision enemy with player, end game

Give player0 the ability to fire missle0

Detect collision between missle0 and enemy, i.e. player1

If collision with missle0 and enemy, cause enemy to disappear

Score?  Increment under various conditions

Make a simple title screen, draw better one later, transfer from title to game

Make gave over screen, transfer from game to game over screen on loss conditions

Is it posible to win?

Is it possible to have multiple copies of player1 for many enemies at once?

Sound?  Simple sounds for foot steps, and/or gun shots, and/or building attacks.  

Music?

## Possible Road Map

Start with simply being able to draw, position, and move basic sprite with joystick.

Build background/playfield, ensure sprite is kept within it.

Once a sprite can be moved, add another sprite which is controlled by the computer, moves randomly.

Add ability to fire missle from player sprite.

Detect collision with missle and computer sprite, remove player sprite as a result.

If score is desired, add a score and increment when player shoots sprite.
