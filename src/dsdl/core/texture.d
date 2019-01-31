module dsdl.core.texture;

import derelict.sdl2.sdl;
import derelict.sdl2.image;
import std.string;
import dsdl.core.renderer;
import dsdl.core.releaseable;
import dsdl.core.error;

enum TextureAccessPattern {
    STATIC = SDL_TEXTUREACCESS_STATIC,
    STREAMING = SDL_TEXTUREACCESS_STREAMING,
    TARGET = SDL_TEXTUREACCESS_TARGET
}

/**
 * An image that can be rendered.
 * Authors: Michael Incardona
 */
class Texture : Releaseable {
    private SDL_Texture* texture;

    private Uint32 _format;
    private int _width;
    private int _height;

    /**
     * Loads a texture from a file.
     * Params:
     *      filePath = path to the texture file
     *      renderer = the renderer to load the texture with
     */
    public this(string filePath, Renderer renderer) {
        this.texture = sdlEnforcePtr!SDLIMGException(
            IMG_LoadTexture(renderer.ptr, toStringz(filePath))
        );
        try {
            _queryTexture();
        } catch (Exception e) {
            this.release();
            throw e;
        }
    }

    /**
     * Creates a texture object tied to an SDL_Texture struct.
     * Params:
     *      texture = pointer to texture struct
     */
    public this(SDL_Texture* texture) {
        if (texture is null) {
            throw new SDLCoreException("Attempt to construct Texture with null", 0);
        }
        this.texture = texture;
        try {
            _queryTexture();
        } catch (Exception e) {
            this.texture = null;
            throw e;
        }
    }

    private void _queryTexture() {
        sdlEnforceZero!SDLCoreException(
            SDL_QueryTexture(this.ptr, &this._format, null, &this._width, &this._height)
        );
    }

    /**
     * Creates a new (blank) texture.
     * The exact contents of the new texture are undefined. It uses the RGBA8888 pixel format.
     * Params:
     *      width = the desired width of the texture
     *      height = the desired height of the texture
     *      rend = the renderer to create the texture with
     *      access = the texture access pattern (default is STATIC)
     */
    public this(int width, int height, Renderer rend,
                TextureAccessPattern access = TextureAccessPattern.STATIC) {
        this._width = width;
        this._height = height;
        this._format = SDL_PIXELFORMAT_RGBA8888;
        this.texture = sdlEnforcePtr!SDLCoreException(
            SDL_CreateTexture(rend.ptr, this._format, cast(int)access, width, height)
        );
    }

    @property {
        public SDL_Texture* ptr() {
            return texture;
        }

        public Uint32 format() {
            return _format;
        }

        public int width() {
            return _width;
        }

        public int height() {
            return _height;
        }
    }

    override public void release() {
        SDL_DestroyTexture(texture);
        texture = null;
    }

}
