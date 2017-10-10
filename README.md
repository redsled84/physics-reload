# physics-reload
Refactor of gbit-platform-shooter to work with the Box2d framework

# Mission JPL3000

## Installing dependencies (via a debian-based terminal)
* Lua 5.2
* Luarocks
* MoonScript
* Love2D (for our game particularly)
#### Lua
```bash
sudo apt install lua5.2
```
#### Luarocks (requires Lua)
```bash
sudo apt install luarocks
```
#### MoonScript
```bash
sudo luarocks install moonscript
```
#### Love2D
```bash
sudo add-apt-repository ppa:bartbes/love-stable
sudo apt update
sudo apt install love
```
Although, you could get the source code of all four, it's easier to use Ubuntu's ```apt```

## How to Run
1. Building MoonScript\*
2. Transpiling MoonScript\*
3. Building Game

#### Building MoonScript
```bash
moon hello_world.moon
```

#### Transpiling MoonScript to Lua
```bash
moonc hello_world.moon
lua hello_world.lua
```
Now each .moon file has been translated to a corresponding Lua file

#### Building Game
You must be typing the commands in the game directory path
```bash
source build.sh
```

\* Not required, but useful if you decide to play around with MoonScript
