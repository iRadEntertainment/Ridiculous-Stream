# Contributing to Ridiculous Stream for Godot

We welcome contributions of all forms! To get started, here's an overview of our project's structure:

## Project Structure

The plug-in runs a pletora of `@tool` scripts in the engine when it gets activated.
- **Plugin Core**: The `addons/ridiculous_stream/RidiculousStream.gd` (class_name `RSMain`) contains all the logic for Twitch chat integration and OBS controls. It is used like an Autoload


## Getting Started

### 1. Set Up Your Development Environment

To contribute to Ridiculous Stream for Godot, you'll need to have Godot 4.x installed on your computer. If you haven't already, download it from the [official Godot website](https://godotengine.org/download).

After installing Godot, fork this repository and clone your fork to your local machine:
```
git clone https://github.com/your-username/ridiculous-stream-for-godot.git
cd ridiculous-stream-for-godot
```

### 2. Explore the Project Structure

Familiarize yourself with the layout of the project. All the custom Class and Nodes that are vital for the plugin have the `RS` appendix as naming convention.

Key directories include:
- `addons/ridiculous_stream/RidiculousStream.gd`: The main plugin code.
- `addons/ridiculous_stream/RSCustom.gd`: Where the custom functionalities live.
- `addons/ridiculous_stream/games/`: Where the in-editor overlays live.
- `addons/ridiculous_stream/classes/`: Where the `RS` custom class are collected live.

### 3. Coding Standards

Let's try to maintain a clean and consistent codebase. Please adhere to:

- Follow [GDScript style guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html).
- Comment your code where necessary to explain complex logic.
- Keep your contributions focused on **one feature or bug fix per pull request**.
- Before starting your work on a new feature or fix, check the project's Issues section to ensure nobody else is already working on it. If you're tackling an existing issue, comment that you're working on it.

### 4. Submitting Your Contributions

Once you've made your changes:

1. Push your changes to your fork.
2. Create a pull request to the main repository.
3. In your pull request description, explain your changes and reference any related issue(s).

For more detailed information on creating a pull request, see GitHub's documentation on [Creating a pull request from a fork](https://help.github.com/articles/creating-a-pull-request-from-a-fork/).

### 56. Stay Involved

After submitting your pull request, stay engaged in the conversation. Reviewers may ask for changes or further clarification. Your contributions are a valuable part of the project's continued growth and improvement.

## Questions?

If you have any questions or need further assistance, feel free to open an issue for general questions or reach out directly to **Dario "iRad" De Vita** via [GitHub](https://github.com/iraddev) or check any ongoing live stream at https://www.twitch.tv/iraddev.

---

We look forward to your contributions. Together, we can make Ridiculous Stream for Godot even better!

