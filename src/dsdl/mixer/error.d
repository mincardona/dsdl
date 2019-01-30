module dsdl.mixer.error;

import derelict.sdl2.mixer;
import dsdl.core.error;

/**
 * Thrown to signify an error in the mixer satellite library.
 */
class SDLMixerException : AbstractSDLException {
    mixin SDLExceptionSubclassThis!(Mix_GetError);
}
