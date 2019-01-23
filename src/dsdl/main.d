import std.stdio;
import std.string;
import std.conv;
import std.experimental.logger;
import std.file;
import core.thread;

import derelict.sdl2.sdl;
import derelict.sdl2.image;
import derelict.sdl2.ttf;

import dsdl.core.sdlutil;
import dsdl.core.renderer;
import dsdl.core.window;
import dsdl.core.texture;
import dsdl.core.inputhandler;
import dsdl.core.event;

int main(string[] args) {
    initSDLModule(SDLModule.MAIN);
    initSDLModule(SDLModule.TTF);
    initSDLModule(SDLModule.IMAGE);

    initLogger();
    auto stderrLogger = new FileLogger(stderr);
    stderrLogger.logLevel = LogLevel.warning;
    sdlLogger.insertLogger("stderr", stderrLogger);

    Window win = new Window("DSDL Demo", 640, 480, WindowType.WINDOWED);
    Renderer rend = new Renderer(win, true, true, "opengl");
    rend.render();

    bool quit = false;
    stdout.flush();
    do {
        SDLEvent e;
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
