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
    
    auto stderrLogger = new FileLogger(stderr);
    stderrLogger.logLevel = LogLevel.warning;
    sdlLogger.insertLogger("stderr", stderrLogger);
    
    Grid!int g = new Grid!int(3, 3, 0);
    for (int i = 0; i < g.area; i++)
        g.set(i, i);
    
    g.addColumnsRight(2, 0);
    
    quitSDLModule(SDLModule.MAIN);
    
    write("Press ENTER...");
    stdout.flush();
    readln();
    
	return 0;
}
