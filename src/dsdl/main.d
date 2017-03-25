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
import dsdl.core.joystick;
import std.conv;
import std.experimental.logger;
import std.file;
import core.thread;

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
    rend.render();
    
    auto nofJoys = Joystick.howManyConnected;
    
    writefln("Found %s connected %s", nofJoys, plural("joystick", nofJoys));
    foreach (i; 0 .. nofJoys) {
        writefln("\t%s", Joystick.getNameOfDevice(i));
    }
    
    bool quit = false;
    
    SDLEvent e;
    
    stdout.flush();
    
    do {
        // Handle events on queue
        while(SDL_PollEvent(&e) != 0) {
            // User requests quit
            if (e.type == SDL_QUIT) {
                quit = true;
            }
        }
        Thread.getThis().sleep(dur!("msecs")(5));
    } while (!quit);
    
    rend.release();
    win.release();
    
    quitSDLModule(SDLModule.TTF);
    quitSDLModule(SDLModule.IMAGE);
    quitSDLModule(SDLModule.MAIN);
    
	return 0;
}

string plural(string s, long howMany) {
    if (howMany != 1) {
        return s ~ "s";
    }
    return s;
}

