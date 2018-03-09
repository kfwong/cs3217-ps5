CS3217 Problem Set 5
==

**Name:** Wong Kang Fei

**Matric No:** A0138862W

**Tutor:** Lai Hoang Dung (Louis)

## Tips

1. CS3217's Gitbook is at https://www.gitbook.com/book/cs3217/problem-sets/details. Do visit the Gitbook often, as it contains all things relevant to CS3217. You can also ask questions related to CS3217 there.
2. Take a look at `.gitignore`. It contains rules that ignores the changes in certain files when committing an Xcode project to revision control. (This is taken from https://github.com/github/gitignore/blob/master/Swift.gitignore).
3. A Swiftlint configuration file is provided for you. It is recommended for you to use Swiftlint and follow this configuration. Keep in mind that, ultimately, this tool is only a guideline; some exceptions may be made as long as code quality is not compromised.
4. Do not burn out. Have fun!

### Rules of Your Game

To capture as many pokemon as possible!

Game Clear when all "catchable" pokemon are caught. Game Over when the pokemons line up with more than 13 rows.

Special Pokemons:
- **Tepig:** Damage adjacent pokemons when it form a clique of more than or equal to 3 fire-types (i.e. Charmander).
- **Raichu:** Damage the row of pokemons when it forms a clique of more than or equal to 3 lightning-types (i.e. Pikachu).
- **Masterball:** Capture any pokemons of same type on the field.
- **Magnemite:** Magnet that affect projectile. It is indestructible by special effects except detached.
- **Gengar:** Ghost type which is uncatchable nor be damaged by other special effects. They can only be scared off from field (detached).

### Problem 1: Cannon Direction

Player can <kbd>tap</kbd> or <kbd>pan</kbd> across the screen. The cannon will follow the direction of player's finger. Once player releases his finger, the cannon will be fired.

I've disable the area below the cannon so the projectile will not be able to shoot downwards. Furthermore, the projectile can only shoot upwards, therefore shooting at 0 and 180 degree is not allowed in order to prevent projectile from bouncing off side walls infinitely.

### Problem 2: Upcoming Bubbles

My design consist of only one `Projectile` and it is reused after each shot, therefore I can preload a multiple `BubbleType` to implement upcoming bubbles.

The actual algorithm uses a `Queue` to store the upcoming bubbles. Given a threshold, the `GameEngine` will reload upcoming bubbles before & after the reloading projectile.

My game shows only one upcoming bubbles for simplicity. Future improvement can be made to the UI such that multiple upcoming bubbles are displayed.

### Problem 3: Integration

This is actually implemented in PS4 for the ease of black box testing. My current design uses variable passing through the Segue. It transforms the current Game Level into array of `GameBubbles` and pass it to the `GameController`. However, this is not the best design in my opinion as it tightly couples controllers and the datastructure that the game depends on.

A better alternative approach is to pass the only filename to the `GameController` and let it decide how to load the data from save file. This bypass fragile coupling from both controllers and the interface is easier for reuse. In this design, both controllers only couple to `DataController`. They can also assume different datastructures to store and display the states as well.

### Problem 4.4

My previous assumption on the special bubbles was incorrect since they are not fired by the `Projectile`, therefore relying on `Projectile` to carry the strategy object is inappropriate. 

However, the Strategy Pattern can still be applied in a reversed direction. In my final design, each `GameBubble` now carries a `BubbleEffectStrategy` object as their property. In short, the effect is executed on `GameBubble` by `GameEngine` when resolving the game state.

![bubble-effect-strategy](https://i.imgur.com/8MuMSlO.png)


`GameEngine` execute the effect through the method defined by `GameBubble`. Each `GameBubble` does not know the exact behaviour since it is masked by the `BubbleEffectStrategy` interface. The effect will only be known when it is executed in runtime.

Since the bubble effect correspond to their `BubbleType`, it will be resolved by the `BubbleType` enum in its `bubbleEffect()` method. This method return the corresponding strategy object to the `GameBubble`.

In addition, the `BubbleEffectStrategy` defines very simple interfaces, easy enough for any developer to understand its purpose without looking at the technical documentation. For example:

- **`explode()` method requires developer to describe what are the affected `GameBubbles`, resolve and return them as an array object.** The required parameters (i.e. `Projectile` that triggers it, and the overall game state) are synthetic sugars passed into the method by the `GameEngine` so the developers can use them to implement the effect. Removal of the `GameBubble` is done by the `GameEngine` so the developers do not have to handle such logic.
- **`explodeAnimation()` method defines the animation to run when this special bubble explodes.** This delegates the responsibility of defining animation from `GameController` to the strategy object.

In case when the bubble effect does not simply apply to just exploding, such as magnetic bubble which only applies its effect on the `Projectile`, then a new interface should be registered in the `BubbleEffectStrategy` interface. A default implementation can be written as `extension` so that existing special bubbles are not affected by such changes.

I find that this design pattern is a perfect fit for this game because I do not have to modify `GameEngine` nor `GameBubble` to register new special bubbles. The only changes I need is to add a new concrete strategy class to describe the special bubble effect, and then register it in the `BubbleType` enum.

#### Implementing Chaining Effects

The corresponding logic to resolve chaining effects are defined in the `GameEngine` under `explodeBubbles()` method.

![](https://i.imgur.com/mMerhgC.png)


The main implementation is written as **recursion**:
1. `GameController` calls to the `explodeBubbles()` method to trigger explosion of first set of bubbles.
2. `GameEngine` remove those bubbles. In return, exploding bubbles return an array of more affected bubbles back to the `explodeBubbles()` method.
3. `explodeBubbles()` method is called again until no more affected bubbles are returned (i.e. empty array).

This implementation makes intuitive sense and is easy to implement. However, the effects are resolved almost instantaneously so it will be difficult for players to visualize which bubble set off explosion of another.

A better improvement can be made such that each set of explosion are pushed into a `Queue`, and `GameController` will handle the animation one by one with reasonable delay. This provides a better game experience to the players.

### Problem 7: Class Diagram

Since there's little changes to my class diagram from PS3-5, I'll be reusing the class diagram from previous PS.

Pardon my decision for not combining the entire class diagram as a whole because I find it counter-productive since it confuse the reader with huge class diagram. According to SE it's better to view fragments of class diagram within context.

I'm including the links for previous PSes for convenience:

- PS3: Level Designer 
    - [https://github.com/cs3217/2018-ps3-kfwong#class-diagram-simplified](https://github.com/cs3217/2018-ps3-kfwong#class-diagram-simplified)
- PS4: Game Engine
    - [https://github.com/cs3217/2018-ps4-kfwong/tree/4d2446282284ef9186816e1f779cd97867c3f9b7#problem-11-class-diagram-simplified](https://github.com/cs3217/2018-ps4-kfwong/tree/4d2446282284ef9186816e1f779cd97867c3f9b7#problem-11-class-diagram-simplified)
- Final Design for BubbleEffect Strategy Pattern
    - [See above on Problem 4.4](#problem-44)

#### PS5 Class Diagram for Integration
Below is the class diagram for integration in PS5, as well as extra view (`UIAnimationView`) that supports the animation effect. By cross referencing the links above should give complete overview of how the game is designed.

![](https://i.imgur.com/mlswS8p.png)

- `MenuController` displays the main menu. It is the entry point of the application.
- `LevelDesignerController` shows the level designer in PS3.
- `LevelSelectionCOntroller` uses a table view and segued as a popover on top of `MenuController`. It allows the player select any saved levels.
- `GameController` controls the game and starts game engine in as it is in PS4. It uses `UIAnimationView` to simplify implementation of the animation effect.

### Problem 8: Testing

#### Previous Test cases:
[https://github.com/cs3217/2018-ps3-kfwong#black-box-testing](https://github.com/cs3217/2018-ps3-kfwong#black-box-testing)
[https://github.com/cs3217/2018-ps4-kfwong#problem-3-testing](https://github.com/cs3217/2018-ps4-kfwong#problem-3-testing)

#### Black Box
##### Select & Play Default Level
| Step     | Actions  | Expected Result |
| -------- | -------- | ----------------|
| 1     | Launch application     | Display main menu with <kbd>Play!</kbd> and <kbd>Edit!</kbd> buttons.     |
| 2     | Press <kbd>Play!</kbd> | Background blurred and a level selection screen is displayed as a popover. Three sample levels are displayed: `sample-level-1`, `sample-level-2` and `sample-level-3`|
| 3     | Randomly pick one of them. | Game area is displayed and player can begin playing. |
| 4     | Press <kbd>EXIT</kbd> at the bottom right of the screen to exit the game area. |

##### Launch Designer
| Step     | Actions  | Expected Result |
| -------- | -------- | ----------------|
| 5     | Repeat step 1     | |
| 6     | Press <kbd>Edit!</kbd> button. | Level designer is displayed. |

##### Play from Level Designer Directly
| Step     | Actions  | Expected Result |
| -------- | -------- | ----------------|
| 7     | Repeat step 5-6    | |
| 8     | Draw any level design using the palette. | |
| 9     | Press <kbd>START</kbd> at the bottom of the screen. | Game area is displyed and player can begin playing. |

##### Cannon Rotation
| Step     | Actions  | Expected Result |
| -------- | -------- | ----------------|
| 10     | Tap anywhere above the cannon horizon.  | Cannon rotate smoothly to the face the tap location. The projectile is fired. |
| 11    | Tap+Hold and Pan anywhere above the cannon horizon. | Cannon rotate smoothly to face the finger location. The projectile is not fired. |
| 12    | Pan below the cannon horizon. | Cannon stops at restricted angle above the cannon horizon. |
| 13    | Release finger below the cannon horizon. | Projectile is fired at the restricted angle above cannon horizon. |
| 14    | Tap below the cannon horizon. | Projectile is not fired. Cannon does not rotate. |

##### Raichu (Lightning Bubble)
![](https://i.imgur.com/FxDAXfs.jpg)

| Step     | Actions  | Expected Result |
| -------- | -------- | ----------------|
| 15       | Draw a level as above using the Level Designer and press <kbd>START</kbd> button to play. | |
| 16       | Shoot the Raichu with pokemon other than Pikachu | Raichu is not destroyed nor its effect triggered. |
| 16       | Shoot the Raichu with a Pikachu projectile when available. | Raichu is destroyed. The row of pokemons where Raichu resides are destroyed. The lightning animation is played on every effected pokemons. |

##### Tepig (Bomb)
| Step     | Actions  | Expected Result |
| -------- | -------- | ----------------|
| 17       | Load `sample-level-2` and play. | |
| 18       | Shoot the Tepig with any pokemon other than Charmander. | Tepig is not destroyed nor its effect triggered|
| 19       | Shoot the Tepig with Charmander. | Tepig is destroyed. The adjacent pokemon are destroyed. The exposion animation is played on every effected pokemons. |

##### Gengar (Indestructible Bubble)
![](https://i.imgur.com/j9RroJ4.jpg)

| Step     | Actions  | Expected Result |
| -------- | -------- | ----------------|
| 20       | Draw a level as above using the Level Designer and press <kbd>START</kbd> button to play. | |
| 21       | Shoot any pokemon on to Gengar to form a grouping of more than 3 | Gengar is not destroyed. |
| 22       | Shoot and trigger the effect of Tepig and Raichu. | Effects are played on top of Gengar, but it is not destroyed. | 
| 24       | Shoot the Squirtle on top to disconnect the rest of pokemon from top row. | Gengar is detached and dropped. |

##### Masterball (Star)
| Step     | Actions  | Expected Result |
| -------- | -------- | ----------------|
| 25       | Load `sample-level-3` and play. ||
| 26       | Shoot any masterball in play. | All pokemons in the game area captured depend on the projectile type. ||

##### Magnemite (Magnet)
![](https://i.imgur.com/7MA1nkr.jpg)

| Step     | Actions  | Expected Result |
| -------- | -------- | ----------------|
| 27       | Draw the Level as above and play. | |
| 28       | Shoot the projectile near the magnemite | The projetile inreases its speend and curve towards the magnet. |

##### Chain Reaction
![](https://i.imgur.com/E4LMHOq.jpg)

| Step     | Actions  | Expected Result |
| -------- | -------- | ----------------|
| 29       | Draw the level as above and play. | |
| 30       | Trigger Raichu's effect when available | The Lightning effect is triggered, setting off other special effect to capture all affected pokemon. |

##### Game Over
| Step     | Actions  | Expected Result |
| -------- | -------- | ----------------|
| 31       | Shoot a line of pokemon until it is more than 13 rows. | The game over is triggered. |

##### Game Clear with empty game area
| Step     | Actions  | Expected Result |
| -------- | -------- | ----------------|
| 32       | Load `sample-level-2` and play. | |
| 33       | Attempt to clear the game so that the game area is completely empty. | Game cleared triggered. |

##### Game Clear with indestructible pokemon
![](https://i.imgur.com/FYFt867.jpg)

| Step     | Actions  | Expected Result |
| -------- | -------- | ----------------|
| 34       | Draw the level as above. ||
| 35       | Attempt to clear the level, leaving only Gengar and Magnemite. | Game cleared triggered. |

#### White Box

##### BubbleEffects

All special bubbles logic are unit testable. The exception is the animation itself.

| Class:Methods     | Configuration Under Test  | Expected Result |
| -------- | -------- | ----------------|
| `Bomb:explode()` | valid active game bubbles | return adjacent active bubbles |
| | empty active game bubbles | return empty array |
| | has no active neighbours | return empty array |
| | neighbours are out of indexes (corners) | result exclude those indexes |
| `Star:explode()` | valid active game bubbles | return active bubbles that matches the projectile itself. |
| | empty active game bubbles | return empty array |
| | has no active bubbles matches the type | return empty array |
| `Lightning:explode()` | valid active game bubbles | return row of active bubbles same index as itself |
| | empty active game bubbles | return empty array |
| | has no active neighbours on the same row | return empty array |
| `Indestructible:explode()` | valid active game bubbles | return empty array |
| | empty active game bubbles | return empty array |
| | has no active neighbours | return empty array |
| `Magnet:explode()` | valid active game bubbles | return adjacent active bubbles |
| | empty active game bubbles | return empty array |
| `Magnet:effectOnProjectileMovement()` | normal configuration | return computed force vector. |
| | projectile has zero distance with magnet. | return computed vector using minimum distance of 30 pixels instead of 0. (prevent divide by zero) |
| `GameController:explodeBubbles()` | active bubbles without special effect | all bubbles are removed from gameEngine.|
|| active bubbles with special effect | the method should recursively destroy bubbles until it return empty array. |
|| active bubbles with indestrutible bubbles. | does not remove indestructible bubbles from game. |
| `GameController:hasClearedAllActiveBubbles()` | empty array | return true |
|| consist of only indestructible bubbles | return true |
|| consist of mixed destructible special bubbles and indestructible bubbles only | return false |
|| consist of only normal bubbles | return false |
|| consist of normal bubbles and special destructible bubbles | return false |
| `BubbleType:bubbleEffect()` | any registered type | corresponding bubble strategy object |
|| any unregistered type (.none, deselect) | return normal |
| `BubbleType:bubbleRootType()` | Lightning and Bomb | return orange and red respectively. |
| | other non-associative type | return itself. |
| `UIAnimationView:init()` *precondition where col and row are non-zero, valid idleSpriteindex | normal configuration | initialize view with multiple evenly cut sprites |

### Problem 9: The Bells & Whistles

1. Added special effects animations to all special bubbles

### Problem 10: Final Reflection

I'm satisfied with my work so far, given that my design goes according to my plan most of the time. I was able to apply design patterns I've learned in this project. However, it's also my first time designing the GameEngine so I didn't know what to plan ahead or expect. I feel that major improvement still can be done to decouple the controller and gameEngine.s

It's regrettable that I wasn't able to implement more bell and whistles due to time constraint. I actually had more plans to make the game more fun (i.e. capture Pokemon with different scores, game sharing feature, weakness against another type etc.)

I spent most of my time trying to understand how the magnetic physics work (more than 6 hours :disappointed: ). Math is not really my forte but I tried my best to implement it! It's still buggy but I guess I can revisit another time.

I've decided not to implement the non-snapping bubble time cost to rework and retest as it adds little value to the game, though I acknowledge that I'll lose my marks :persevere:.

It's my first time designing a game and I actually enjoy it a lot! It's a tiring but satisfying to work on!

### Footnotes
#### Known Bugs
- Snapping will fail if the magnet increases the thrust of projectile.
