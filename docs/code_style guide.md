# Style Guide
> [!IMPORTANT]  
> For folders and file names **inside** the `godot_game` folder please use **snake_case** (this avoids case sensitivity issues).

## Naming Conventions

- Class and Node names use **PascalCase**.
- Function and Variable names use **snake_case**.
- Constants and Enums use **CONSTANT_CASE**

![Case Reference](case%20type.png)

## Type Hinting

In some cases where it may be ambiguous, you can declare the expected type of value that a particular variable will store, or a function will return.

Type hinting in Godot is done much in the same way as python.

For a function `function_name() -> return_type`
```py
var health: int = 10
```
For a variable `variable_name: type`
```py
func example(amount: int) -> void:
```

## Doc Strings and Comments

In Godot doc strings are denoted by lines beginning with `##` while comments use a single `#`.

```python
# TODO fix this returning negative values.
func example_func():
## Description of function.
## etc.
```
---
> [!TIP]
> When in doubt, follow Python's PEP8 conventions or Consult Godot's [official style guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html).
