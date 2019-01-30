module dsdl.ttf.error;

import derelict.sdl2.ttf;
import dsdl.core.error;

/**
 * Thrown to signify an error in the TTF satellite library.
 */
class SDLTTFException : AbstractSDLException {
    mixin SDLExceptionSubclassThis!(TTF_GetError);
}
