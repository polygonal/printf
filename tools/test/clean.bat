@echo off
if not exist ..\..\haxelib.json (
	echo wrong working directory!
	pause
	exit
)

if exist RunTests.n (
	del RunTests.n
)

if exist bin (
	rmdir bin /S /Q
)