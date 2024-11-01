# CRDataModEditor
A simple data mod editor for the game Cosmic Reach
To use, click Project>Open>select folder with the mod you want to edit

## Currently supports editing
- block events
- blocks

## Important notes
- the root folder of the project contains the `defaultAssets` folder which includes the game's source files. Not uploaded due to the amount of files and probable irrelevance of them in the future
- custom `defaultAssets` can be loaded into the user's folder(`%appdata%/crdme` on windows)
- if you're having issues when exporting your block-events, try adding spaces between strings, colons: and braces{} when using json representation of params in `set params`

`defaultAssets` folder must contain the assets presented in the same way they would be presented in CR's `mods` folder
