import std.stdio;
import std.string;
import std.conv;
import std.experimental.logger;
import std.file;
import core.thread;
import std.datetime;
import std.math;

import derelict.sdl2.sdl;
import derelict.sdl2.ttf;

import dsdl.core.sdlutil;
import dsdl.core.renderer;
import dsdl.core.window;
import dsdl.core.inputhandler;
import dsdl.core.event;

class Demo {
    struct Paddle {
        double x;
        double y;
        int width;
        int thickness;
    }

    struct Ball {
        double x;
        double y;
        double xv;
        double yv;
        int side;
    }

    Paddle padBottom;
    Paddle padTop;
    Ball ball;

    Window win;
    Renderer rend;

    bool isLeftDown;
    bool isRightDown;

    int frameCountdown;

    enum PADDLE_WIDTH = 50;
    enum PADDLE_THICKNESS = 20;
    enum BALL_SIDE = 30;
    enum BALL_HSPEED = 150;  // pixels per second
    enum BALL_VSPEED = 80;
    enum PADDLE_SPEED = 150;

    this(Window win, Renderer rend) {
        this.win = win;
        this.rend = rend;

        frameCountdown = 60;

        isLeftDown = false;
        isRightDown = false;

        padTop = Paddle((win.width - PADDLE_WIDTH)/2, 0, PADDLE_WIDTH, PADDLE_THICKNESS);
        padBottom = padTop;
        padBottom.y = win.height - PADDLE_THICKNESS;
        ball = Ball(win.width / 2.0, win.height / 2.0, BALL_HSPEED, BALL_VSPEED, BALL_SIDE);
    }

    void run() {
        rend.drawColor = SDLColor(0, 0, 0, SDL_ALPHA_OPAQUE);
        rend.clear();
        rend.render();

        auto clock = new dsdl.core.clock.Clock;
        clock.go();

        for(;;) {
            doRender();
            int direction;
            bool quit;

            getEvents(direction, quit);
            if (quit) {
                break;
            }

            ulong delta_us = clock.checkMicros();
            clock.reset();

            updateTick(direction, delta_us);
        }
    }

    private void doRender() {
        rend.drawColor = SDLColor(0, 0, 0, 255);
        rend.clear();

        rend.drawColor = SDLColor(0, 255, 0, 255);
        rend.fillRect(SDLRect(cast(int)round(padTop.x), cast(int)round(padTop.y), padTop.width, padTop.thickness));
        rend.fillRect(SDLRect(cast(int)round(padBottom.x), cast(int)round(padBottom.y), padBottom.width, padBottom.thickness));
        rend.fillRect(SDLRect(cast(int)round(ball.x), cast(int)round(ball.y), ball.side, ball.side));

        rend.render();
    }

    private void getEvents(out int direction, out bool quit) {
        SDLEvent e;
        // Handle events on queue
        while (!quit && SDL_PollEvent(&e) != 0) {
            switch (e.type) {
            case SDL_QUIT:
                quit = true;
                break;
            case SDL_KEYUP:
                goto case;
            case SDL_KEYDOWN:
                auto keyevent = cast(SDL_KeyboardEvent)e.key;
                auto key = keyevent.keysym.scancode;
                if (key == SDL_SCANCODE_LEFT) {
                    isLeftDown = (keyevent.state == SDL_PRESSED ? true : false);
                } else if (key == SDL_SCANCODE_RIGHT) {
                    isRightDown = (keyevent.state == SDL_PRESSED ? true : false);
                }
                break;
            default:
                break;
            }
        }

        direction = 0;
        if (isLeftDown) {
            direction--;
        }
        if (isRightDown) {
            direction++;
        }
    }

    private void updateTick(int direction, ulong delta_us) {
        if (frameCountdown > 0) {
            frameCountdown--;
            return;
        }
        double paddleDist = cast(double)(delta_us) / 1000000 * PADDLE_SPEED;
        double ballDist = cast(double)(delta_us) / 1000000;

        if (padTop.x < ball.x) {
            padTop.x += paddleDist;
        } else {
            padTop.x -= paddleDist;
        }

        padBottom.x += direction * paddleDist;
        ball.x += ball.xv * ballDist;
        ball.y += ball.yv * ballDist;

        if (intersects(ball, padTop) || intersects(ball, padBottom)) {
            ball.yv = -ball.yv;
        }

        if (ball.x <= 0 || ball.x >= win.width - ball.side) {
            ball.xv = -ball.xv;
        }
    }

    private bool intersects(Ball ball, Paddle paddle) {
        bool c0 = ball.x             < paddle.x + paddle.width;
        bool c1 = ball.x + ball.side > paddle.x;
        // for a normal y axis we would flip the below
        // >, < signs
        bool c2 = ball.y             < paddle.y + paddle.thickness;
        bool c3 = ball.y + ball.side > paddle.y;
        return c0 && c1 && c2 && c3;
    }
}

int main(string[] args) {
    initSDLModule(SDLModule.MAIN);
    initSDLModule(SDLModule.TTF);

    initLogger();
    auto stderrLogger = new FileLogger(stderr);
    stderrLogger.logLevel = LogLevel.warning;
    sdlLogger.insertLogger("stderr", stderrLogger);

    Window win = new Window("DSDL Demo", 640, 480, WindowType.WINDOWED);
    Renderer rend = new Renderer(win, true, true, "opengl");

    stdout.flush();

    Demo demo = new Demo(win, rend);
    demo.run();

    rend.release();
    win.release();

    quitSDLModule(SDLModule.TTF);
    quitSDLModule(SDLModule.IMAGE);
    quitSDLModule(SDLModule.MAIN);

	return 0;
}
