.PHONY: clean
default: opencv naive
clean:
	rm -f opencv naive

opencv:
	g++ -o opencv opencv.cpp `pkg-config --cflags --libs opencv4` -std=c++11

naive:
	g++ -o naive naive.cpp `pkg-config --cflags --libs opencv4` -std=c++11
