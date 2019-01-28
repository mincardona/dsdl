module dsdl.core.error;

import std.string;
import derelict.sdl2.sdl;

class SDLException : Exception {
    int _code;

    public this(string msg, int code, string file = __FILE__, ulong line = cast(ulong)__LINE__) {
        super(msg, file, line);
        this._code = code;
    }

    public this(int code, string file = __FILE__, ulong line = cast(ulong)__LINE__) {
        super(fromStringz(SDL_GetError()).idup, file, line);
        this._code = code;
    }

    @property int code() {
        return _code;
    }
}

void sdlEnforceZero(int code, string file = __FILE__, ulong line = cast(ulong)__LINE__) {
    if (code != 0) {
        throw new SDLException(code, file, line);
    }
}

void sdlEnforceNatural(int code, string file = __FILE__, ulong line = cast(ulong)__LINE__) {
    if (code < 0) {
        throw new SDLException(code, file, line);
    }
}
