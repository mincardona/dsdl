module dsdl.ttf.font;

import derelict.sdl2.sdl;
import derelict.sdl2.ttf;
import std.string;
import dsdl.core.releaseable;

/**
 * Represents a font.
 * Authors: Michael Incardona
 */
class Font : Releaseable {
    /** Underlying C SDL font */
    private TTF_Font* font;

    /**
     * Initializes this Font object based on a specified font.
     * Params:
     *      font = the SDL_Font this Font object should use
     */
    public this(TTF_Font* font) {
        this.font = font;
    }

    /**
     * Initializes this Font object with a given font file.
     * Params:
     *      filePath = path to the font file
     *      ptsize = the font size, in points (usually equivalent to pixels)
     *      index = the font to use from the given file (default 0)
     */
    public this(string filePath, int ptsize, int index = 0) {
        auto cstr = toStringz(filePath);
        this.font = TTF_OpenFontIndex(cstr, ptsize, index);
    }

    @property {
        /**
         * A pointer to the underlying SDL_Font*
         */
        public TTF_Font* ptr() { return this.font; }
    }

    override public void release() {
        TTF_CloseFont(this.font);
        font = null;
    }

}
