import std.random;
import std.math;
import std.stdio;

struct vec2(T) {
    public T x;
    public T y;
    
    public this(T x, T y) {
        this.x = x;
        this.y = y;
    }
}

alias vec2d = vec2!double;
alias vec2f = vec2!float;
alias vec2i = vec2!int;
alias vec2L = vec2!long;

alias cord = long;
alias vec2c = vec2!cord;

enum Heading {
    NONE = -1,
    UP = 0,
    RIGHT = 1,
    DOWN = 2,
    LEFT = 3
}

Heading rot90c(Heading h) {
    if (h == Heading.NONE) {
        return h;
    }
    return cast(Heading)((h + 1) % 4);
}

Heading rot90cc(Heading h) {
    if (h == Heading.NONE) {
        return h;
    }
    return cast(Heading)((h - 1) % 4);
}

Heading rot180(Heading h) {
    if (h == Heading.NONE) {
        return h;
    }
    return cast(Heading)((h + 2) % 4);
}

vec2!T getUnitVec2(T)(Heading h) {
    vec2!T rvec = vec2!T(cast(T)0, cast(T)0);
    if (h == Heading.NONE) {
        return rvec;
    } else if (h == Heading.LEFT || h == HEADING.RIGHT) {
        rvec.x = cast(T)(2 - h);
    } else {
        rvec.y = cast(T)(1 - h);
    }
}

