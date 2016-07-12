module dsdl.core.renderer;

import derelict.sdl2.sdl;
import derelict.sdl2.ttf;
import dsdl.core.sdlutil;
import dsdl.core.window;
import dsdl.core.texture;
import dsdl.ttf.font;
import std.string;
import dsdl.core.releaseable;

/**
 * Renders graphics to a window using hardware acceleration.
 * Authors: Michael Incardona
 */
class Renderer : Releaseable {

    public static immutable HIGH_QUALITY = true;
    public static immutable LOW_QUALITY = false;

    private SDL_Renderer* renderer;
    private SDLColor _drawColor;
    
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
     */
    public this(Window window, bool doVsync, bool doRenderTexture) {
        Uint32 flags = SDL_RENDERER_ACCELERATED;
        if (doVsync)
            flags |= SDL_RENDERER_PRESENTVSYNC;
        if (doRenderTexture)
            flags |= SDL_RENDERER_TARGETTEXTURE;
        renderer = SDL_CreateRenderer(window.ptr, -1, flags);

        drawColor = SDLColor(0, 0, 0, ALPHA_OPAQUE);

        SDL_RendererInfo rinfo;
        // returns 0 on success
        SDL_GetRendererInfo(renderer, &rinfo);
        // .idup ensures that the converted string is an immutable deep copy
        _name = fromStringz(rinfo.name).idup;
        _isVsyncEnabled = areFlagsSet(rinfo.flags, SDL_RENDERER_PRESENTVSYNC);
        _isSoftware = areFlagsSet(rinfo.flags, SDL_RENDERER_SOFTWARE);
        _isAccelerated = areFlagsSet(rinfo.flags, SDL_RENDERER_ACCELERATED);
        _isTargetTextureSupported = areFlagsSet(rinfo.flags, SDL_RENDERER_TARGETTEXTURE);
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
    public Texture renderTextToTexture(string txt, Font font, bool highQuality, in SDLColor fg) {
        SDL_Surface* surf = null;
        if (highQuality)
            surf = TTF_RenderText_Blended(font.ptr, toStringz(txt), fg);
        else
            surf = TTF_RenderText_Solid(font.ptr, toStringz(txt), fg);
        SDL_Texture* tex = SDL_CreateTextureFromSurface(this.ptr, surf);
        if (tex is null)
            return null;
        else
            return new Texture(tex);
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
                                             in SDLColor fg, in SDLColor bg) {
        SDL_Surface* surf = null;
        surf = TTF_RenderText_Shaded(font.ptr, toStringz(txt), fg, bg);
        SDL_Texture* tex = SDL_CreateTextureFromSurface(this.ptr, surf);
        if (tex is null)
            return null;
        else
            return new Texture(tex);
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
                           bool highQuality, in SDLColor fg) {
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
                           in SDLColor fg, in SDLColor bg) {
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
	 * Renders the buffer to this renderer's associated window.
	 */
	public void present() {
	    SDL_RenderPresent(this.ptr);
	}

    /**
     * Renders a texture.
     * Params:
     *      img = the texture to render
     *      src = the portion of the texture to render
     *      dest = the target area
     */
    public void renderTexture(Texture img, in SDLRect src, in SDL_Rect dest) {
		SDL_RenderCopy(this.ptr, img.ptr, &src, &dest);
		return;
	}

    /**
     * Clears the render buffer.
     */
    public void clear() {
        SDL_RenderClear(this.ptr);
    }

    public void presentAndClear() {
        this.present();
        this.clear();
    }

    /**
     * Frees all resources used by this renderer.
     */
    override public void release() {
        SDL_DestroyRenderer(renderer);
        renderer = null;
    }

    public bool checkIntegrity() {
        return renderer !is null;
    }
    
    override public string toString() {
        return format("%s { vsync=%s, software=%s, accelerated=%s, targetTexture=%s }", 
            isVsyncEnabled, isSoftware, isAccelerated, isTargetTextureSupported);
    }

}
