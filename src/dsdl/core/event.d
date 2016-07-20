module dsdl.core.event;
import derelict.sdl2.sdl;

alias SDL_Event SDLEvent;

string getScancodeName(SDL_Scancode scancode) {
    return fromStringz(SDL_GetScancodeName(scancode)).idup;
}

string getKeycodeName(SDL_Keycode keycode) {
    return fromStringz(SDL_GetKeycodeName(keycode)).idup;
}

SDL_Scancode getScancodeFromName(string name) {
    return SDL_GetScancodeFromName(toStringz(name));
}

SDL_Keycode getKeycodeFromName(string name) {
    return SDL_GetKeycodeFromName(toStringz(name));
}
