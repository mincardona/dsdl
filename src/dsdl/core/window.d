module dsdl.core.window;

import derelict.sdl2.sdl;
import std.string;
import dsdl.core.releaseable;

/**
 * An application window, as defined by the operating system.
 * Authors: Michael Incardona
 */
class Window : Releaseable {
    private SDL_Window* window;
    private int _width;
    private int _height;
    private WindowType _type;
    private string _title;

    /**
     * Creates a new window.
     * Params:
     *      title = The window's title
     *      xsize = the width of the window (resolution)
     *      ysize = the height of the window (resolution)
     *      type = the widnow type
     */
    public this(string title, int xsize, int ysize, WindowType type) {
        this._type = type;
        this._title = title;
        SDL_WindowFlags winflags = SDL_WINDOW_SHOWN;
        winflags |= this._type;
        this.window = SDL_CreateWindow(
                                toStringz(this.title),
                                SDL_WINDOWPOS_CENTERED,
                                SDL_WINDOWPOS_CENTERED,
                                xsize,
                                ysize,
                                winflags);
        _width = xsize;
        _height = ysize;
    }

    /**
     * Changes the fullscreen mode of this window, or disables fullscreen
     * Params:
     *      t = the fullscreen mode to use
     */
    public void setFullscreen(FullscreenType fsType) {
        SDL_SetWindowFullscreen(window, cast(SDL_WindowFlags)fsType);
    }

    @property {

        /**
         * Pointer to the underlying SDL_Window
         */
        public SDL_Window* ptr() {
            return window;
        }
        
        /**
         * the window/application title (shows in the titlebar)
         */
        public string title() {
            return this._title;
        }
        
        public string title(string tl) {
            SDL_SetWindowTitle(this.window, toStringz(tl));
            this._title = tl;
            return tl;
        }

        /**
         * The window width
         */
        public int width() {
			return _width;
		}

        /**
         * The window height
         */
		public int height() {
			return _height;
		}

        /**
         * The window type (bordered or borderless)
         */
        public WindowType type() {
            return this._type;
        }

    }

    override public void release() {
        SDL_DestroyWindow(this.window);
        window = null;
    }
}

enum WindowType {
    WINDOWED = SDL_WINDOW_SHOWN,
    BORDERLESS_WINDOWED = SDL_WINDOW_BORDERLESS
}

enum FullscreenType {
    WINDOWED = 0,
    FULLSCREEN = SDL_WINDOW_FULLSCREEN,
    FULLSCREEN_DESKTOP = SDL_WINDOW_FULLSCREEN_DESKTOP
}
