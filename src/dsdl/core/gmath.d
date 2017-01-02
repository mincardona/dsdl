module dsdl.core.gmath;

import std.math;
import std.random;

// uses Box-Muller transform (https://en.wikipedia.org/wiki/Box-Muller_transform)
// normally distributed number in [0, 1)
double randNorm() {
    // nan indicates there is no cached number
    static double cache = double.nan;
    if (!isNaN(cache)) {
        double t = cache;
        cache = double.nan;
        return t;
    }
    double m1 = sqrt(-2.0 * log(uniform01));
    double m2 = 2.0 * PI * uniform01();
    // generates cos(m2) + i*sin(m2)
    // Twice as fast as computing them separately on x86
    // according to the phobos documentation.
    // https://dlang.org/phobos/std_math.html#.expi
    auto both = expi(m2);
    // real part == cosine
    cache = m1 * both.re;
    // imaginary part == sine
    return m1 * both.im;
}

double randNorm(double mean, double stddev) {
    return randNorm() * stddev + mean;
}

double randNormClamp() {
    double result = randNorm();
    if (abs(result) >= 3) {
        result = 0;         // shenanigans
    }
    return result;
}

double randNormClamp(double mean, double stddev) {
    return randNormClamp() * stddev + mean;
}

// [)
uint randNormUint(uint min, uint max) {
    return cast(uint)(randNorm() * (max - min) + min);
}

