module dsdl.core.texturebackedrenderer;

import dsdl.core.renderer;
import dsdl.core.window;
import dsdl.core.texture;
import derelict.sdl2.sdl;
import dsdl.core.releaseable;

/**
 * This renderer renders to a texture buffer before rendering the buffer to the screen.
 *  This allows for an application to render at an aspect ratio/resolution different from that of
 *  the display, while still being able to fill the height of the window/screen.
 *
 * The renderer will render to a texture of specified width and height, and then render
 *  this texture onto a window of different dimensions (in horizontal or vertical letterbox if necessary)
 *
 * Authors: Michael Incardona
 */
class TextureBackedRenderer : Renderer {
    /** The texture render target */
    private Texture texTarget;
    /** true if this renderer should currently be rendering to the texture rather than the window */
    private bool _useTextureAsTarget;
    /** The window this renderer draws to */
    private Window win;

// ctors

    /**
     * Creates a hardware-accelerated texture renderer with black draw color.
     */
    public this(Window window, bool doVsync, Texture ttarget) {
        super(window, doVsync, true);
        win = window;
        texTarget = ttarget;
        useTextureAsTarget = true;
    }

    // creates a new target access texture
    public this(Window window, bool doVsync, int twidth, int theight) {
        super(window, doVsync, true);
        win = window;
        texTarget = new Texture(twidth, theight, this);
        useTextureAsTarget = true;
    }

// Private methods

    /**
     * Switches this renderer between render-to-texture and render-to-window modes
     */
    @property private bool useTextureAsTarget(bool val) {
        if (this.texture is null)
            return _useTextureAsTarget;
        _useTextureAsTarget = val;
        if (val)
            SDL_SetRenderTarget(this.ptr, texTarget.ptr);
        else
            SDL_SetRenderTarget(this.ptr, null);
        return val;
    }

// Public methods

    @property public Texture texture(Texture t) {
        this.texTarget = t;
        return t;
    }

    @property public Texture texture() {
        return this.texTarget;
    }

    /**
     * Renders the texture buffer to the screen. The texture buffer is stretched to fit the
     *  vertical height of the window/screen, and centered with bars on
     *  either size.
     */
    override public void present() {
        int x = cast(int)((win.width - texTarget.width)/2) - 1;
        SDL_Rect src;
        src.x = src.y = 0;
        src.h = texTarget.height;
        src.w = texTarget.width;
        SDL_Rect dest;
        dest.x = x;
        dest.y = 0;
        dest.h = win.height;
        dest.w = win.width - 2 * x;
        this.useTextureAsTarget = false;
        this.renderTexture(texTarget, src, dest);
        super.present();
        this.useTextureAsTarget = true;
    }

    override public bool checkIntegrity() {
        return super.checkIntegrity() && (texTarget !is null) && (win !is null);
    }

    // closes the texture target and calls super.release()
    override public void release() {
        if (texTarget !is null)
            texTarget.release();
        texTarget = null;
        super.release();
    }
    
    /**
     * Equivalent to "this.present(); this.clear();" but more optimized
     */
    override public void presentAndClear() {
        int x = cast(int)((win.width - texTarget.width)/2) - 1;
        SDL_Rect src;
        src.x = src.y = 0;
        src.h = texTarget.height;
        src.w = texTarget.width;
        SDL_Rect dest;
        dest.x = x;
        dest.y = 0;
        dest.h = win.height;
        dest.w = win.width - 2*x;
        this.useTextureAsTarget = false;
        this.renderTexture(texTarget, src, dest);
        super.present();
        super.clear();
        this.useTextureAsTarget = true;
        SDL_RenderClear(this.ptr);
    }

    override public void clear() {
        this.useTextureAsTarget = true;
        SDL_RenderClear(this.ptr);
        this.useTextureAsTarget = false;
        super.clear();
        this.useTextureAsTarget = true;
    }
}
