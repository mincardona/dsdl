module dsdl.core.renderer;

import std.regex;
import std.stdio;
import derelict.sdl2.sdl;
import derelict.sdl2.ttf;
import dsdl.core.sdlutil;
import dsdl.core.window;
import dsdl.core.texture;
import dsdl.ttf.font;
import std.string;
import dsdl.core.releaseable;
import dsdl.core.sdlutil;

/**
 * Renders graphics to a window using hardware acceleration.
 * Authors: Michael Incardona
 */
class Renderer : Releaseable {

    /** Used to specifiy high quality for certain operations. */
    public static enum HIGH_QUALITY = true;
    /** Used to specify low quality for certain operations. */
    public static enum LOW_QUALITY = false;

    private SDL_Renderer* renderer;
    private SDLColor _drawColor;

    private Texture renderTarget;

    /** Name of the renderer used (e.g. directx, opengl) */
    private string _name;
    /** Is this renderer vsynced? */
    private bool _isVsyncEnabled;
    private bool _isSoftware;
    private bool _isAccelerated;
    private bool _isTargetTextureSupported;

    /**
     * Creates a hardware-accelerated renderer with black draw color.
     * Params:
     *      window = the window to use with this renderer
     *      doVsync = true if this renderer should use vertical sync
     *      doRenderTexture = true if this renderer must be capable of render-to-texture
     *      prefer = string representing a regular expressiont o match to a preferred renderer name
     */
    public this(Window window, bool doVsync, bool doRenderTexture, string prefer = "") {
        Uint32 flags = SDL_RENDERER_ACCELERATED;
        if (doVsync) {
            flags |= SDL_RENDERER_PRESENTVSYNC;
        }
        if (doRenderTexture) {
            flags |= SDL_RENDERER_TARGETTEXTURE;
        }

        renderTarget = null;

        SDL_RendererInfo rinfo;
        auto ex = regex(prefer);
        int maxRender = SDL_GetNumRenderDrivers();
        int renderIndex;

        for (renderIndex = 0; renderIndex < maxRender; renderIndex++) {
            SDL_GetRenderDriverInfo(renderIndex, &rinfo);
            auto indexName = fromStringz(rinfo.name);
            if (!matchFirst(indexName, ex).empty) {
                break;
            }
        }

        if (renderIndex >= maxRender) {
            renderIndex = -1;
        }

        renderer = SDL_CreateRenderer(window.ptr, renderIndex, flags);

        drawColor = SDLColor(0, 0, 0, ALPHA_OPAQUE);
        // returns 0 on success
        SDL_GetRendererInfo(renderer, &rinfo);
        // .idup ensures that the converted string is an immutable deep copy
        _name = fromStringz(rinfo.name).idup;
        _isVsyncEnabled = areFlagsSet(rinfo.flags, SDL_RENDERER_PRESENTVSYNC);
        _isSoftware = areFlagsSet(rinfo.flags, SDL_RENDERER_SOFTWARE);
        _isAccelerated = areFlagsSet(rinfo.flags, SDL_RENDERER_ACCELERATED);
        _isTargetTextureSupported = areFlagsSet(rinfo.flags, SDL_RENDERER_TARGETTEXTURE);
        this.clear();
    }

    @property {
        public SDL_Renderer* ptr() {
            return renderer;
        }

        /** The color used to draw on this renderer (also used for clearing the renderer) */
        public SDLColor drawColor() {
            return _drawColor;
        }

        public SDLColor drawColor(SDLColor color) {
            _drawColor = color;
            SDL_SetRenderDrawColor(
                renderer, _drawColor.r, _drawColor.g, _drawColor.b, _drawColor.a);
            return _drawColor;
        }

        /** The name of the render "device" being used by ths renderer (e.g. opengl, directx, etc.) */
        public string name() {
            return _name;
        }

        public bool isVsyncEnabled() {
            return _isVsyncEnabled;
        }

        public bool isSoftware() {
            return _isSoftware;
        }

        public bool isAccelerated() {
            return _isAccelerated;
        }

        public bool isTargetTextureSupported() {
            return _isTargetTextureSupported;
        }
    }

    /**
     * Renders text to a texture.
     * Params:
     *      txt = the text to render
     *      font = the font to render the text in
     *      highQuality = true (HIGH_QUALITY) if text smoothing/antialiasing should be used
     *      fg = the color to draw the text in
     * Returns: a texture containing the rendered text
     */
    public Texture renderTextToTexture(string txt, Font font, bool highQuality, SDLColor fg) {
        SDL_Surface* surf = null;
        auto cstr = toStringz(txt);
        if (highQuality) {
            surf = TTF_RenderText_Blended(font.ptr, cstr, fg);
        } else {
            surf = TTF_RenderText_Solid(font.ptr, cstr, fg);
        }
        SDL_Texture* tex = SDL_CreateTextureFromSurface(this.ptr, surf);
        if (tex is null) {
            return null;
        } else {
            return new Texture(tex);
        }
    }

    /**
     * Renders text to a texture with a colored background (text smoothing/antialiasing is used).
     * Params:
     *      txt = the text to render
     *      font = the font to render the text in
     *      fg = the color to draw the text in
     *      bg = the desired color of the text's highlighted background
     * Returns: a texture containing the rendered text
     */
    public Texture renderTextToTextureShaded(string txt, Font font,
                                             SDLColor fg, SDLColor bg) {
        SDL_Surface* surf = null;
        surf = TTF_RenderText_Shaded(font.ptr, toStringz(txt), fg, bg);
        SDL_Texture* tex = SDL_CreateTextureFromSurface(this.ptr, surf);
        if (tex is null) {
            return null;
        } else {
            return new Texture(tex);
        }
    }

    /**
     * Renders text to this renderer.
     * Params:
     *      txt = the text to render
     *      font = the font to render the text in
     *      x = the x-coordinate of the upper-left corner of the text's target location
     *      y = the y-coordinate of the upper-left corner of the text's target location
     *      highQuality = true (HIGH_QUALITY) if text smoothing/antialiasing should be used
     *      fg = the color to draw the text in
     */
    public void renderText(string txt, Font font, int x, int y,
                           bool highQuality, SDLColor fg) {
        Texture tex = renderTextToTexture(txt, font, highQuality, fg);
        renderTexture(tex, x, y);
    }

    /**
     * Renders text with a colored background to this renderer (text smoothing/antialiasing is used).
     * Params:
     *      txt = the text to render
     *      font = the font to render the text in
     *      x = the x-coordinate of the upper-left corner of the text's target location
     *      y = the y-coordinate of the upper-left corner of the text's target location
     *      fg = the color to draw the text in
     *      bg = the desired color of the text's highlighted background
     */
    public void renderTextShaded(string txt, Font font, int x, int y,
                                 SDLColor fg, SDLColor bg) {
        Texture tex = renderTextToTextureShaded(txt, font, fg, bg);
        renderTexture(tex, x, y);
    }

    /**
     * Renders a texture.
     * Params:
     *      img = the texture to render
     *      x = the x-coordinate of the upper left corner of the texture's target lcoation
     *      y = the y-coordinate of the upper left corner of the texture's target lcoation
     */
    public void renderTexture(Texture img, int x, int y) {
		SDLRect pos;
		pos.x = x;
		pos.y = y;
		pos.w = img.width;
		pos.h = img.height;
		SDL_RenderCopy(this.ptr, img.ptr, null, &pos);
		return;
	}

    /**
     * Sets a texture as the render target, or restores the target to the
     * default.
     *
     * A texture target must be created with the TARGET access pattern.
     *
     * @warning Bypassing this method to set the texture target through the
     * SDL_Renderer* will cause problems.
     *
     * @warning Resetting the render target to the default will not free the old
     * render target.
     *
     * @param tex the texture to use as a target, or null to reset to the
     * default target
     */
    public void setRenderTarget(Texture tex) {
        // TODO: handle errors when after calling SDL_SetRenderTarget
        if (tex is null) {
            this.renderTarget = null;
            SDL_SetRenderTarget(this.ptr, null);
        } else {
            // also store the texture in this object
            this.renderTarget = tex;
            SDL_SetRenderTarget(this.ptr, tex.ptr);
        }
    }

    /**
     * Gets the current render target
     * @return the current render target, or null for the default target.
     */
    public Texture getRenderTarget() {
        return renderTarget;
    }

    /**
     * Sets the logical resolution of the rendering output.
     * @param size the resolution
     */
    public void setLogicalSize(Resolution size) {
        SDL_RenderSetLogicalSize(this.ptr, cast(int)size.x, cast(int)size.y);
    }

    /**
     * Gets the logical resolution of the rendering output.
     * @return the logical resolution, or (0, 0) if it was never set
     */
    public Resolution getLogicalSize() {
        Resolution res;
        int x, y;
        SDL_RenderGetLogicalSize(this.ptr, &x, &y);
        res.x = cast(uint)x;
        res.y = cast(uint)y;
        return res;
    }

	/**
	 * Renders the buffer to this renderer's associated target
	 */
	public void render() {
	    SDL_RenderPresent(this.ptr);
	}

    /**
     * Renders a texture.
     * Params:
     *      img = the texture to render
     *      src = the portion of the texture to render
     *      dest = the target area
     */
    public void renderTexture(Texture img, SDLRect src, SDL_Rect dest) {
		SDL_RenderCopy(this.ptr, img.ptr, &src, &dest);
		return;
	}

    /**
     * Clears the render buffer.
     */
    public void clear() {
        SDL_RenderClear(this.ptr);
    }

    public void renderAndClear() {
        this.render();
        this.clear();
    }

    /**
     * Frees all resources used by this renderer. Does NOT free the render target.
     */
    override public void release() {
        SDL_DestroyRenderer(renderer);
        renderer = null;
    }

    override public string toString() {
        return format("%s { vsync=%s, software=%s, accelerated=%s, targetTexture=%s }",
            name, isVsyncEnabled, isSoftware, isAccelerated, isTargetTextureSupported);
    }

}
