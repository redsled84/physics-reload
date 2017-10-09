run:
	moonc *.moon
	mv $(shell find *.lua -type f -not \( -name 'main.lua' -o -name 'conf.lua' \)) build/
	love .