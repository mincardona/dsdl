You will need to install dub, the D package manager, to build the project (https://code.dlang.org/packages/dub).
You do not need to download the Derelict libraries yourself; dub will download them for you when you build the project.

Use the command "dub build --config=xyz --build=abc" to make the project, where:

xyz =
    exe
        Creates a test .exe file in REPO/bin/ based on main.d
        To use the test .exe, you will need the SDL, SDL_image, SDL_mixer, and SDL_ttf runtime binaries. Drop them in the REPO/bin folder.
        SDL: https://libsdl.org/
        SDL_image: https://www.libsdl.org/projects/SDL_image/
        SDL_mixer: https://www.libsdl.org/projects/SDL_mixer/
        SDL_ttf: https://www.libsdl.org/projects/SDL_ttf/
        On Ubuntu, install the libsdl2-dev, libsdl2-image-dev, libsdl2-mixer-dev, snd libsdl2-ttf-dev packages.
    lib
        Creates a static .lib file in REPO/lib/

abc =
    debug
        Debug build mode
    release
        Release build mode (activates compiler optimizations, etc.)
    docs
        Creates documentation from source in REPO/docs/

Possible future additions:

    High priority:
        - Better KB + mouse input support
        - Gamepad and haptic support
        - Text input
        - Timer callbacks
        - Better render-to-texture support
        - Geometric primitives

    Low priority:
        - Wrap SDL_net (low priority because std.socket provides similar functionality)
        - Touchscreen support
        - Audio recording (whenever it gets implemented in SDL)
