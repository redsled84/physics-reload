BUILD_FILES := $(shell find *lua -maxdepth 1 -type f -not \( -name "main.lua" -o -name "conf.lua" \))

all:
	moonc *.moon
	mv $(BUILD_FILES) ./build
	love .