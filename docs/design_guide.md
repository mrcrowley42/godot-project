# **Sprite Design Guide**

### To ensure consistency between art assets, the following guidelines should be followed when creating sprites.

- Sprites are drawn using a `2px` wide square brush.
- In Godot the texture filter of a `Sprite2D` using a sprite is set to `Nearest` to maintain sharp pixels.
- To give otherwise static sprites life, at least `3 frames` of animation (2 additional frames) should be made by tracing over the previous frame.

> <img src="../godot_game/images/creature_sprites/confused-0.png" width=160px/>
> <img src="../godot_game/images/creature_sprites/confused-1.png" width=160px/>
> <img src="../godot_game/images/creature_sprites/confused-2.png" width=160px/>
><img src="animation_example.gif" width=160px/>

***

> ### For reference the dimensions of the standard Creature are:
> - Height: `132px`.
> - Width: `112px`.
