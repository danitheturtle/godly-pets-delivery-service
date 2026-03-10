This is built-in to godot. read tutorial on it

* Expose simple function for translation strings.
* Folder under /assets to hold loc strings. Split into multiple json dictionaries.
* Use replace string so variables can be inserted into the string from call site
* Figure out if pre-ready init of strings is possible to avoid UI flicker
* Use signal on the i18n singleton for locale switching. Everywhere with text needs to listen
* Locale switching available from main menu or settings menu