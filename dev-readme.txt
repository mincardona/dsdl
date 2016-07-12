Download the SDL2, SDL-Image, SDL-TTF, and SDL-Mixer runtime binaries and dump the dlls/readmes in the "bin" directory.

Use "dub build --config=xyz --build=abc" to make the project

xyz =
    exe: test .exe file
    lib: static .lib file
    
abc =
    debug
    release
    docs
    