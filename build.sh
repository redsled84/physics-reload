moonc *.moon
find build/*lua -type f -not \( -name "collisionMasks.lua" -o -name "utils.lua" -o -name "world.lua" \) -exec rm {} \;
find *lua -maxdepth 1 -type f -not \( -name "main.lua" -o -name "conf.lua" \) -exec mv {} build \;
love .