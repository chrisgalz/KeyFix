# KeyFix
If you have a 2016-2017 MacBook Pro TouchBar with broken keys that repeat, this code lets you prevent the annoying key repeat.
This is only for keys that repeat. This will not work with keys that are stuck or do not work at all.

Desktop App: Add to login items, and modify the settings with the GUI
Command Line Version: Modify main.m variables to fit your keyboard issues.

Modify *glitchedKey* to specify the key on your keyboard that is glitched.

Modify *minimumKeyRepeatRate* to specify the duration to lock the key to prevent repeating.

In this github project is both a command line and GUI version.

Software Credits:
-written by chrisgalz
-uses method by indragiek, https://gist.github.com/indragiek/4166038

Icon Credits:
-Designed by chrisgalz with glyphs from
-Keyboard by Bonturi Luca from the Noun Project
-Hammer by Rflor from the Noun Project

This is similar to a keylogger, but the input is only checked to run a backspace on key repeats caused on the hardware level of the Mac.