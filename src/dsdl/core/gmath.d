module dsdl.core.gmath;

import std.math;
import std.random;

/**
 * Generates a standard-normally-distributed double (mean 0, stddev 1).
 * @return a random number
 */
double randNorm() {
    // uses Box-Muller transform with a cache for the second number

    // nan indicates there is no cached number
    static double cache = double.nan;
    if (!isNaN(cache)) {
        double t = cache;
        cache = double.nan;
        return t;
    }
    double m1 = sqrt(-2.0 * log(uniform01()));
    double m2 = 2.0 * PI * uniform01();
    // generates cos(m2) + i*sin(m2)
    // Twice as fast as computing them separately on x86
    // according to the phobos documentation.
    // https://dlang.org/phobos/std_math.html#.expi
    // apparently deprecated now per compiler message?
    auto both = expi(m2);
    // real part == cosine
    cache = m1 * both.re;
    // imaginary part == sine
    return m1 * both.im;
}

/**
 * Generates a normally-distributed double with a given mean and standard
 * deviation.
 * @param mean the mean
 * @param stddev the standard deviation
 * @return a random number
 */
double randNorm(double mean, double stddev) {
    return randNorm() * stddev + mean;
}

/**
 * Generates a normally-distributed double with all values outside of 3
 * standard deviations replaced with the mean.
 * @return the random number
 */
double randNormClamp() {
    double result = randNorm();
    if (abs(result) >= 3) {
        result = 0;         // shenanigans
    }
    return result;
}

/**
 * Same as the no-argument version, but with a custom mean and standard
 * deviation.
 * @param mean the mean
 * @param stddev the standard deviation
 * @return the random number
 */
double randNormClamp(double mean, double stddev) {
    return randNormClamp() * stddev + mean;
}
