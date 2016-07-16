import std.stdio;
import dsdl.core.sdlutil;
import dsdl.core.vec2f;
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
import std.conv;
import std.experimental.logger;

int main(string[] args) {
    string rootLoadingDir = "c:/";
    string imgSubdir = "/img/";
    string musSubdir = "/mus/";
    string sfxSubdir = "/sfx/";
    
    initSDLModule(SDLModule.MAIN);
    initSDLModule(SDLModule.IMAGE);
    initSDLModule(SDLModule.TTF);
    
    auto stderrLogger = new FileLogger(stderr);
    stderrLogger.logLevel = LogLevel.warning;
    sdlLogger.insertLogger("stderr", stderrLogger);
    
    Window win = new Window("main.d", 640, 480, WindowType.WINDOWED);
    Renderer rend = new Renderer(win, true, true);
    
    TextureBank tbank = new TextureBank();
    tbank.add("bottle", new Texture("tex/bottle.png"));
    
    Font font = new Font("fon/FreePixel.ttf");
    
    rend.renderTexture(tbank.get("bottle"), 0, 0);
    rend.renderText(renderer.toString(), font, 10, 100, Renderer.HIGH_QUALITY, SDLColor(0, 0, 0));
    
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
    
    quitSDLModule(SDLModule.TTF);
    quitSDLModule(SDLModule.IMAGE);
    quitSDLModule(SDLModule.MAIN);
    
    write("Press ENTER...");
    stdout.flush();
    readln();
    
	return 0;
}
