CXX = g++

.PHONY: all
all: symver_hack.so

.PHONY: clean
clean:
	rm -f symver_hack.so

symver_hack.so: symver_hack.s symver_hack.ld
	$(CXX) -shared -Wl,--version-script,symver_hack.ld -o $@ symver_hack.s
