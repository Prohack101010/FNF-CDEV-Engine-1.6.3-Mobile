#!/bin/sh
# SETUP FOR MAC AND LINUX SYSTEMS!!!
# REMINDER THAT YOU NEED HAXE INSTALLED PRIOR TO USING THIS
# https://haxe.org/download
cd ..
echo Makking the main haxelib and setuping folder in same time..
haxelib setup ~/haxelib
echo Installing dependencies...
echo This might take a few moments depending on your internet speed.
haxelib git flixel https://github.com/PsychExtendedThings/flixel 5.6.1 --quiet
haxelib install flixel-addons 3.2.2 --quiet
haxelib install flixel-ui 2.4.0 --quiet #I don't know why is it exist
haxelib install hscript 2.4.0 --quiet
haxelib install tjson 1.4.0 --quiet #for fucking mods system (haxe.Json brokes the modlist)
haxelib install hxCodec --quiet #That clearly my repo
haxelib git hxcpp https://github.com/beihu235/hxcpp --quiet #Just a normal hxcpp
haxelib git lime https://github.com/HomuHomu833-haxelibs/lime int-delta --quiet #repo owner helped to fix termux problem
haxelib install openfl 9.3.3 --quiet #Most stable version of openfl
echo Finished!