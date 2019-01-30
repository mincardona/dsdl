module dsdl.core.error;

import std.traits;
import derelict.sdl2.sdl;
import derelict.sdl2.image;

/**
 * Abstract superclass for SDL and satellite library exceptions.
 * It stores an int error code in addition to a message.
 */
abstract class AbstractSDLException : Exception {
    private int _code;

    public this(string msg, int code, string file = __FILE__, ulong line = cast(ulong)__LINE__) {
        super(msg, file, line);
        this._code = code;
    }

    @property int code() {
        return _code;
    }
}

/**
 * A convenient mixin template for creating constructors for subclasses of
 * AbstractSDLException. See SDLCoreException for a usage example.
 *
 * @param ErrorTextFunction the name of the function to call to get the last
 * error string (e.g. SDL_GetError). The function must take no arguments and
 * return a char* or const(char)*
 */
mixin template SDLExceptionSubclassThis(alias ErrorTextFunction)
if (isSomeFunction!ErrorTextFunction && arity!ErrorTextFunction == 0
    && (is(ReturnType!ErrorTextFunction == const(char)*)
        || is(ReturnType!ErrorTextFunction == char*)))
{
    /**
     * Construct the exception with a custom int code and a custom message.
     */
    public this(string msg, int code, string file = __FILE__, ulong line = cast(ulong)__LINE__) {
        super(msg, code, file, line);
    }

    /**
     * Construct the exception with a custom int code and a message derived
     * from the error string function given as a template parameter.
     */
    public this(int code, string file = __FILE__, ulong line = cast(ulong)__LINE__) {
        // keep this import here so client files do not have to import it
        import std.string : fromStringz;
        super(fromStringz(ErrorTextFunction()).idup, code, file, line);
    }
}

/**
 * Thrown to signify an error in the core SDL library.
 */
class SDLCoreException : AbstractSDLException {
    // use SDL_GetError to get the last error string
    mixin SDLExceptionSubclassThis!(SDL_GetError);
}

/**
 * Thrown to signify an error in the IMG satellite library.
 */
class SDLIMGException : AbstractSDLException {
    mixin SDLExceptionSubclassThis!(IMG_GetError);
}

/**
 * If code is not zero, throw an AbstractSDLException-derived exception of the
 * given type with that code.
 */
void sdlEnforceZero(ExceptionType)(int code, string file = __FILE__, ulong line = cast(ulong)__LINE__)
if (is(ExceptionType : AbstractSDLException)) {
    if (code != 0) {
        throw new ExceptionType(code, file, line);
    }
}

/**
 * Same as sdlEnforceZero, but throw only when the code is negative.
 */
void sdlEnforceNatural(ExceptionType)(int code, string file = __FILE__, ulong line = cast(ulong)__LINE__)
if (is(ExceptionType : AbstractSDLException)) {
    if (code < 0) {
        throw new ExceptionType(code, file, line);
    }
}
