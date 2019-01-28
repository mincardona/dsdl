module dsdl.core.sdlutil;

import derelict.sdl2.sdl;
import derelict.sdl2.image;
import derelict.sdl2.ttf;
import derelict.sdl2.mixer;
import std.file;
import std.string;
import std.stdio;
import std.typecons;
import std.experimental.logger;
import std.traits;

// BEGIN SECTION CONSTANTS_AND_TYPES
version (Windows) {
    enum SDL2_DL_NAME = "SDL2.dll";
    enum MIXER_DL_NAME = "SDL2_mixer.dll";
    enum IMG_DL_NAME = "SDL2_image.dll";
    enum TTF_DL_NAME = "SDL2_ttf.dll";
}

enum ALPHA_OPAQUE = SDL_ALPHA_OPAQUE;
enum ALPHA_TRANSPARENT = SDL_ALPHA_TRANSPARENT;

enum MICROS_PER_S = 1000000;
enum MS_PER_S = 1000;

alias SDLColor = SDL_Color;
alias SDLRect = SDL_Rect;
alias SDLPoint = SDL_Point;

alias Resolution = Tuple!(uint, "x", uint, "y");

// This exists for compatibility with mixplayer: MixPlayer.hookMusicFinished (C <-> D compatibility)
extern(C) alias MixPlayerCallback = void function();

enum SDLModule {
    MAIN, IMAGE, TTF, MIXER, NET
}

enum InitState {
    NOT_INIT, INIT, QUIT
}

// END SECTION CONSTANTS_AND_TYPES

private InitState[SDLModule] moduleStates = null;

// END SECTION VARIABLES_AND_TYPES


// TODO: BUG: Currently, assigning a module state before querying or intializing
//       the array causes a null dereference.
//       Find a way to make the compiler not complain about a static initialization!

InitState queryModuleState(SDLModule mod) {
    if (moduleStates is null) {
        initModuleStates();
    }
    return moduleStates[mod];
}

private void initModuleStates() {
    moduleStates = [
        SDLModule.MAIN: InitState.NOT_INIT,
        SDLModule.IMAGE: InitState.NOT_INIT,
        SDLModule.TTF: InitState.NOT_INIT,
        SDLModule.MIXER: InitState.NOT_INIT,
        SDLModule.NET: InitState.NOT_INIT
    ];
}

/**
 * Logger used by DSDL code. This logger is initialized by initSDLModule() or initLogger()
 * and has no loggers attached to it until client code adds them.
 */
private MultiLogger _sdlLogger = null;

@property {
    MultiLogger sdlLogger() {
        return _sdlLogger;
    }
}

void initLogger() {
    _sdlLogger = new MultiLogger();
}

bool initSDLModule(SDLModule mod) {
    if (!_sdlLogger) {
        initLogger();
    }
    if (!moduleStates) {
        initModuleStates();
    }
    bool returnCode = false;
    if (queryModuleState(mod) == InitState.NOT_INIT) {
        final switch (mod) {
            case SDLModule.MAIN:
                // Load the core SDL2 library
                DerelictSDL2.load();
                returnCode = SDL_Init(SDL_INIT_EVERYTHING) >= 0;
                moduleStates[SDLModule.MAIN] = InitState.INIT;
                break;
            case SDLModule.IMAGE:
                // Load the SDL2_image library
                DerelictSDL2Image.load();
                returnCode = ((IMG_Init(IMG_INIT_PNG) & IMG_INIT_PNG) == IMG_INIT_PNG);
                moduleStates[SDLModule.IMAGE] = InitState.INIT;
                break;
            case SDLModule.TTF:
                // Load the SDL2_ttf library
                DerelictSDL2ttf.load();
                returnCode = TTF_Init() != -1;
                moduleStates[SDLModule.TTF] = InitState.INIT;
                break;
            case SDLModule.MIXER:
                // Load the SDL2_mixer library
                DerelictSDL2Mixer.load();
                Mix_Init(MIX_INIT_MP3 | MIX_INIT_FLAC);
                returnCode = Mix_OpenAudio(MIX_DEFAULT_FREQUENCY, MIX_DEFAULT_FORMAT, 1, 1024) != -1;
                moduleStates[SDLModule.MIXER] = InitState.INIT;
                break;
            case SDLModule.NET:
                break;
        }
    }
    return returnCode;
}

/**
 * Quits an SDL module.
 * Params:
 *      mod the module to quit
 * Returns: an error code
 */
int quitSDLModule(SDLModule mod) {
    int code = 0;
    if (queryModuleState(mod) == InitState.INIT) {
        final switch (mod) {
            case SDLModule.MAIN:
                SDL_Quit();
                break;
            case SDLModule.IMAGE:
                code = IMG_Quit();
                break;
            case SDLModule.TTF:
                TTF_Quit();
                break;
            case SDLModule.MIXER:
                Mix_Quit();
                break;
            case SDLModule.NET:
                break;
        }
        moduleStates[mod] = InitState.QUIT;
    }
    return code;
}

/**
 * Quits all SDL modules.
 */
void quitAllSDLModules() {
    foreach (SDLModule mod; EnumMembers!SDLModule) {
        quitSDLModule(mod);
    }
}

/**
 * Returns all lines from a file which are not prefixed by '#' as a string array
 * Also skips empty lines ( "" ) and lines containing only whitespace
 */
void getLines(string fname, out string[] lines) {
    lines.length = 0;
    File f;
    try {
        f = File(fname, "r");
        string line;
        while ((line = f.readln()) !is null) {
            line = strip(line);
            if (line == "") {
                continue;
            }
            lines.length++;
            lines[$-1] = line;
        }
    } finally {
        f.close();
    }
}

/**
 * Exception thrown when the data in a file or other input is not correctly formatted.
 */
class DataFormatException : Exception {
    public this(string message) {
        super(message);
    }
}

/**
 * Determines whether a group of ORed flags includes another set of ORed flags
 * Params:
 *      flagPile = The group of flags ORed together to search
 *      flags = The flag or group of flags to search fro in flagPile
 * Returns: true if all bits in flags are set in flagPile; false otherwise
 */
bool areFlagsSet(ulong flagPile, ulong flags) {
    return (flagPile & flags) != 0;
}

/**
 * Determines whether a path points to an extant file (and not a directory, etc.)
 * Params:
 *      path = path to the object
 * Returns: true if the path points to an object which exists and is a file; false otherwise
 */
bool isFileAndExists(in string path) {
    return exists(path) && isFile(path);
}
