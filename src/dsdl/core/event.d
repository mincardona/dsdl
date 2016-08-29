module dsdl.core.event;
import derelict.sdl2.sdl;
import derelict.sdl2.functions;
import std.string;

alias SDLEvent = SDL_Event;

string getScancodeName(SDL_Scancode scancode) {
    return fromStringz(SDL_GetScancodeName(scancode)).idup;
}

string getKeycodeName(SDL_Keycode keycode) {
    return fromStringz(SDL_GetKeyName(keycode)).idup;
}

SDL_Scancode getScancodeFromName(string name) {
    return SDL_GetScancodeFromName(toStringz(name));
}

SDL_Keycode getKeycodeFromName(string name) {
    return SDL_GetKeyFromName(toStringz(name));
}
