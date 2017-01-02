import std.stdio;
import std.string;
import derelict.sdl2.sdl;
import derelict.sdl2.image;
import derelict.sdl2.ttf;
import dsdl.core.sdlutil;
import dsdl.core.sdlutil;
import dsdl.core.vec2;
import dsdl.core.renderer;
import dsdl.core.texturebackedrenderer;
import dsdl.core.window;
import dsdl.core.texture;
import dsdl.core.grid;
import dsdl.ttf.font;
import dsdl.core.sprite;
import dsdl.core.texturebank;
import dsdl.mixer.mixplayer;
import dsdl.mixer.musicchunk;
import dsdl.core.inputhandler;
import dsdl.core.releaseable;
import dsdl.core.event;
import std.conv;
import std.experimental.logger;
import std.file;

int main(string[] args) {
    string rootLoadingDir = "c:/";
    string imgSubdir = "/img/";
    string musSubdir = "/mus/";
    string sfxSubdir = "/sfx/";
    
    initSDLModule(SDLModule.MAIN);
    initSDLModule(SDLModule.TTF);
    initSDLModule(SDLModule.IMAGE);
    
    initLogger();
    auto stderrLogger = new FileLogger(stderr);
    stderrLogger.logLevel = LogLevel.warning;
    sdlLogger.insertLogger("stderr", stderrLogger);
    
    Window win = new Window("main.d", 640, 480, WindowType.WINDOWED);
    Renderer rend = new Renderer(win, true, true, "opengl");
    
    TextureBank tbank = new TextureBank();
    tbank.add("bottle", new Texture("spacequest.png", rend));
    
    Font font = new Font("FreePixel.ttf", 12);
    
    rend.renderTexture(tbank.get("bottle"), 0, 0);
    rend.renderText(rend.toString(), font, 10, 100, Renderer.HIGH_QUALITY, SDLColor(255, 0, 0));
    
    rend.render();
    
    bool quit = false;
    
    SDLEvent e;
    
    do {
        // Handle events on queue
        while(SDL_PollEvent(&e) != 0) {
            // User requests quit
            if (e.type == SDL_QUIT) {
                quit = true;
            }
        }
    } while (!quit);
    
    font.release();
    tbank.removeAllAndRelease();
    rend.release();
    win.release();
    
    quitSDLModule(SDLModule.TTF);
    quitSDLModule(SDLModule.IMAGE);
    quitSDLModule(SDLModule.MAIN);
    
	return 0;
}
