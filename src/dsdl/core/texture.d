module dsdl.core.texture;

import derelict.sdl2.sdl;
import derelict.sdl2.image;
import std.string;
import dsdl.core.renderer;
import dsdl.core.releaseable;

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
    public this(in string filePath, Renderer renderer) {
        this(IMG_LoadTexture(renderer.ptr, toStringz(filePath)));
	}

    /**
     * Creates a texture object tied to an SDL_Texture struct.
     * Params:
     *      texture = pointer to texture struct
     */
	public this(SDL_Texture* texture) {
		this.texture = texture;
		SDL_QueryTexture(this.ptr, &this._format, null, &this._width, &this._height);
	}

    /**
     * Creates a new (blank) texture.
     * The texture is marked as a possible render target, and the exact contents of the new texture are undefined.
     * Params:
     *      width = the desired width of the texture
     *      height = the desired height of the texture
     *      rend = the renderer to create the texture with
     */
	public this(int width, int height, Renderer rend) {
	    this._width = width;
	    this._height = height;
	    this._format = SDL_PIXELFORMAT_RGBA8888;
	    this.texture = SDL_CreateTexture(
                rend.ptr, this._format, SDL_TEXTUREACCESS_TARGET, width, height);
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
