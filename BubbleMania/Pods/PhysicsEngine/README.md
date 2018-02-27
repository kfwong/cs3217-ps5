CS3217 Problem Set 4
==

**Name:** Wong Kang Fei

**Matric No:** A0138862W

**Tutor:** Lai Hoang Dung (Louis)

## Tips

1. CS3217's Gitbook is at https://www.gitbook.com/book/cs3217/problem-sets/details. Do visit the Gitbook often, as it contains all things relevant to CS3217. You can also ask questions related to CS3217 there.
2. Take a look at `.gitignore`. It contains rules that ignores the changes in certain files when committing an Xcode project to revision control. (This is taken from https://github.com/github/gitignore/blob/master/Swift.gitignore).
3. A Swiftlint configuration file is provided for you. It is recommended for you to use Swiftlint and follow this configuration. Keep in mind that, ultimately, this tool is only a guideline; some exceptions may be made as long as code quality is not compromised.
4. Do not burn out. Have fun!

## Problem 1.1 Class Diagram (Simplified)

![class-diagram](https://i.imgur.com/7qfi9mo.png)


The architecture is mainly separated into four high level components. They are:

1. `PhysicEngine` contains physics related protocols which gives the game units physical properties.

2. `GameEngine` maintains the states of the game. It defines basic operations that manipulate the game state. It is modelled as a [Facade](https://sourcemaking.com/design_patterns/facade) to encapsulate the complexity, therefore makes it easier for client to define game logic. It also makes use of the [Delegation](https://en.wikipedia.org/wiki/Delegation_pattern) to delegates game logic to other classes. The `GameEngine` is unaware of the views but keeping track of `GameBubble` and `GameProjectile` virtually.

3. `GameRenderer` synchronize with device refresh rate to update the `GameEngine`, therefore creating a game loop.

4. `GameController` has two extensions under its scope, namely `BubbleGridRenderer` that handles bubble grid view on the display, and `GameLoop` that defines the game logic. All game logic can be found in `GameLoop` extension. I moved some overriding functions from the base class here, such as `touchBegan()` because the game logic also relies on touch input from users. This is to ensure that the extension responsibility is cohesive.

### Creating `GameBubble` and `GameProjectile` declaratively

The basic concept here is to break down and regroup each GameUnit's properties & behaviour as reusuable component. We can then assign these components to game units using different combination of the components at hand.

This is hard by traditional OOP because multiple inheritance is not allowed. By leveraging Swift's `protocol` & `extension`, we can provide default implementation to the protocol we defined. Moreover, we can set conditions such that only classes that inherits from `GameObject` will be able to access default implementation, otherwise the client will have to provide custom concrete implementation.

The benefits of such design is that we will have similar to declarative syntax in our `GameBubble` and `GameProjectile` class, for example:

```swift
class GameBubble: GameObject, Hexagonal, CollidableCircle {...}
class GameProjectile: GameObject, Geometrical, CollidableCircle {...}
```

As a consequence of using default implementation, the client does not need to provide any overriding functions in higher level at all, which makes the base class code base cleaner.

Each individual components also conforms to Open/Closed Principle whenever new GameUnits are introduced to future change.

## Problem 1.2 Extend design to support more complex game logic

As mentioned in one of the [PS3 Question](https://github.com/cs3217/2018-ps3-kfwong#problem-33), I'll be using [Strategy Pattern](http://www.oodesign.com/strategy-pattern.html) to define the `GameProjectile` behaviour. In short, `GameProjectile` will carry such strategy object (a.k.a algorithm encapsulated as object). `GameController` will then execute that strategy through an interface and update the view accordingly.

![projectile-strategy-pattern](https://i.imgur.com/J4zSuyt.png)

To answer the question with an example, `GameProjectile` will carry a `WildCardProjectileStrategy` that conforms to the `ProjectileStrategy` protocol. Upon reaching the game state, `GameController` execute the strategy through the interface defined by `ProjectileStrategy` (without knowing underlying algorithm). This will remove all the bubble of same color. `GameController` then update the view against the `GameEngine`'s result.

## Problem 2.1 Handling user input for angle

### Angle

The angle between two points along a horizontal x-axis can be computed using Pythagoras Theorem:

![angle](https://i.imgur.com/aXeCvUu.png)

The formula is
```swift
x-component = projectile.x - touchpoint.x
y-component = projectile.y - touchpoint.y

angle-θ = arctan(y-component / x-component)
```

### Firing Movement Upwards

Given the angle, we can use vector equation to simulate movement:

```swift
moveX -= thrust * cos(angle)
moveY -= thrust * sin(angle)
```

The projectile will update the x-y coordinates as the renderer update the `GameEngine`. We can also programmatically restrict the angle the user can fire the projectile.

As a bonus, reflecting off side walls is simply negate the x-component.

## Problem 3: Testing

I've integrated the Level Designer from PS3 to assist with black box testing. Tester can create any level design to start their testing against a specific level easily. You can use the save/load function to switch between different levels for testing.

#### Important notes
The minimal level designer is for testing only, so tester should **always design the level such that all bubbles are connected to the top row**. Otherwise, the level will start with dangling bubbles, but detach after the projectile is fired for the first time. This will be fixed in PS5 production.

### Testing on Empty Canvas
#### Firing movement 
| Step     | Actions  | Expected Result |
| -------- | -------- | ----------------|
| 1     | Launch application     | Display Level Designer with empty grid.     |
| 2     | Tap the `START` button second from bottom left| A gameplay area is displayed with initial projectile in the middle of the screen |
| 3     | Tap above the projectile. | The bubble shoot along the direction the tester tapped on. |

#### Automatic reloading projectile
| Step     | Actions  | Expected Result |
| -------- | -------- | ----------------|
| 4     | Tap anywhere to fire projectile. | Once the projectile stop its movement, a new random projectile appears in the middle of the screen. |

#### Adjusting angle
| Step     | Actions  | Expected Result |
| -------- | -------- | ----------------|
| 5     | Tap and slide finger across the space above the projectile to adjust the angle.    | (No visual at this point, will add projection in later PS.) |
| 6     | Lift up finger when satisfied. | The projectile will fire towards the direction of the last touchpoint. |

#### Restricted angle
| Step     | Actions  | Expected Result |
| -------- | -------- | ----------------|
| 7        | Tap the left space below the projectile. | Projectile fire towards a fixed angle on the left. |
| 8        | Tap the right space below the projectile. | Projectile fire towards a fixed angle on the right. |

#### Collision of side walls
| Step     | Actions  | Expected Result |
| -------- | -------- | ----------------|
| 9        | Tap to the left of projectile. | Projectile fire towards the left, bounching off left screen when it collides with screen edge. |
| 10       | Tap to the right of projectile. | Projectile fire towards the right, bouncing off the right screen when it collides with screen edge. |
| 11       | Tap below the left/right space of projectile to fire with restricted angle. | The projectile bounces off multiple times when it hits left/right screen edge.

#### Collision of top wall & snap to grid
| Step     | Actions  | Expected Result |
| -------- | -------- | ----------------|
| 12       | Tap anywhere on the screen. | Projectile fire upwards. Once it collide with top wall, it stop and snap to grid. |

#### Collision between Bubble and Projectile and snapping
| Step     | Actions  | Expected Result |
| -------- | -------- | ----------------|
| 13       | Shoot the projectile such that it collides with bubbles on the grid. | The projectile snaps to the nearest cell connected to the bubble it collides with. |

#### Exit gameplay area
| Step     | Actions  | Expected Result |
| -------- | -------- | ----------------|
| 14       | Tap the `Exit` button on the bottom right of the screen. | The gameplay area closes. Level Designer is displayed. |

### Testing with mock level

#### Snap bubble together if same type of bubbles form grouping of two or less 
| Step     | Actions  | Expected Result |
| -------- | -------- | ----------------|
| 15       | Use Level Designer to draw a grouping of 1 with any color of your choice onto the **top row of the grid**. | |
| 16       | Tap `START` button. | Gameplay area is displayed with the level you designed in step 15. | 
| 17       | Shoot towards the grouping when you get a projectile of same color. | Projectile snap to cell to form a connected group of 2. |

#### Fade bubbles if same type of bubbles form grouping of three or more
| Step     | Actions  | Expected Result |
| -------- | -------- | ----------------|
| 18       | Use Level Designer to draw a grouping of 2 or more with any same type of bubble onto the **top row of the grid**. | |
| 19       | Tap `START` button. | Gameplay area is displayed with the level you designed in step 18. | 
| 20       | Shoot towards the grouping when you get a projectile of same color. | Projectile snap to cell to form a connected group of 3 or more and fade away as a group. |

#### Detach bubbles if bubbles are disconnected from top row
![](https://i.imgur.com/CglW2ep.png)

| Step     | Actions  | Expected Result |
| -------- | -------- | ----------------|
| 21       | Use Level Designer to draw the level as above. | |
| 22       | Shoot the red grouping when you get the red projectile. | Dangling blue bubbles on the grid falls and fade away. |
| 23       | Repeat step 21-22 with different colors compositions. |

#### Collision between a bubble and a screen edge
![](https://i.imgur.com/GfTMyJ5.png)

| Step     | Actions  | Expected Result |
| -------- | -------- | ----------------|
| 24       | Use Level Designer to draw the level as above.   |                 |
| 25       | Shoot the projectile such that it bounces off side walls at least once and hit the bubbles. | The projectile bounces off side walls successfully and snap to bubble when it collides with another bubble. |

#### Fade Bubbles when projectile snap to connect disconnected groupings of same kind
![](https://i.imgur.com/14xrRys.png)

| Step     | Actions  | Expected Result |
| -------- | -------- | ----------------|
| 26       | Use Level Designer to draw the level as above.   |
| 27       | Shoot a red projectile in between the gap so two red groupings are connected. | both red groupings fade away. |
| 28       | Repeat step 26-27 with different colors compositions. |

#### Detach multiple disconected grouping
![](https://i.imgur.com/7dtW6QU.png)

| Step     | Actions  | Expected Result |
| -------- | -------- | ----------------|
| 29       | Use Level Designer to draw the level as above.   |
| 30       | Shoot a red projectile towards the red so red groupings are removed from play. | Orange, green and blue groupings are detached. |
| 28       | Repeat step 28-29 with different colors compositions. |

#### Game Over alert (Not required but to prevent the game from freezing)
| Step     | Actions  | Expected Result |
| -------- | -------- | ----------------|
| 29       | Shoot multiple projectile until the it reaches more than 13 rows | A Game over alert is displayed with two options. |
| 30       | Select "Yes please!" | The level is reset to the original state. |
| 31       | Repeat 29-30. | |
| 32       | Select "No I give up!" | The gameplay area closes. Level Designer is displayed. |

### Whitebox Testing

#### `PhysicsEngine`
All default implementation can be unit tested.

`Collidable Circle` 
- check if `isCollidingWith()` is true/false given a hardcoded coordinates overlapping/non-overlapping circle
- check if `isCollidingWithScreenSideEdge()` is true/false given a hardcoded coordinates that is outside/inside of left/right screen.
- check if `isCollidingWithScreenTopEdge()` is true/false given a hardcoded coordinates that is outside/inside of top screen

`Hexagonal`
- check if `neighbourIndexes()` return indexes indicated by the offset vectors (including negative and positive discrete indexes)

`Geometrical`
- check if `verticalAngleFromSelf()` return angle in radian for any positive or negative values.

#### `GameEngine`
`GameBubble` should test together with `GameProjectile` to check if it receives update from observer pattern.

`GameProjectile`
- check if `fire()` create movement for projectile with respect to the angle and thrust value.
- check if `normalizedBearing()` calculates restricted min/max angle correctly.
- check if `snapToPoint()` move the projectile to the specified point.

#### Game Logic
Prepopulate `GameEngine` with a virtual state using `addActiveGameBubble()` method.

- check if `getActiveNeighours()` return list of `GameBubble` that are currently in game.
- check if `neighbourIndexes()` return list of valid neighbour indexes given a `GameBubble`. Negative values and out of bounds indexes should not be in the list.
- check if `getConnectedGameBubbles()` given any active `GameBubble`. It should return a list of `GameBubbles` that connect to the source.
- check if `getDisconnectedGameBubbles()` return list of `GameBubble` that are disconnected from top row.

#### GameRenderer
- check if the `start()` method synchronize with device refresh rate and create a game loop. The delegate pattern method `onGameLoopUpdate()` should be tested together.

#### GameController
- check if `recoverLevelData()` repopulate the grid with list of `Bubble` models. The grid should be populated with respective colors and correct positions

## Footnotes

### Modelling `GameBubble` as hexagons

#### Odd-r Offset Coordinates 
![](https://i.imgur.com/9n5Iowb.png)

`GameEngine` can determine the position of `GameBubble` by providing sections and items count.

#### Neighbour offset vectors
![](https://i.imgur.com/tmrI2SW.png)

Using these information, we can simply model the game using mathematical functions, including algorithms such as BFS. Although the `Graph` data structure can be more flexible for future extension, this is sufficient to cover the current problem set and is easier to work with.

Reference: [https://www.redblobgames.com/grids/hexagons/](https://www.redblobgames.com/grids/hexagons/)
