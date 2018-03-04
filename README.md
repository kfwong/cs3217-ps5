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

Please save your diagram as `class-diagram.png` in the root directory of the repository.

### Problem 8: Testing

Your answer here


### Problem 9: The Bells & Whistles

Your answer here


### Problem 10: Final Reflection

Your answer here
