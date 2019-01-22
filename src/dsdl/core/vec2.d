module dsdl.core.vec2;

import std.math;
import std.conv;

alias vec2d = vec2!double;
alias vec2f = vec2!float;
alias vec2i = vec2!int;
alias vec2l = vec2!long;

/**
 * Represents a two-dimensional vector quantity.
 * Authors: Michael Incardona
 * TODO: optimize magnitude mutator
 */
struct vec2(T)
if (__traits(isArithmetic, T) && !__traits(isUnsigned, T))
{
    public T x;
    public T y;

    /**
     * Creates a new 2D vector with the given component lengths
     * Params:
     *      x = the magnitude of the x component
     *      y = the magnitude of the y component
     */
    public this(T x, T y) {
        this.x = x;
        this.y = y;
    }

    /**
     * Computes a unit vector (vector of magnitude 1) which points in
     *      the same direction as this vector
     */
    public vec2!T unit() {
        return this / this.magnitude;
    }

    /**
     * The magnitude of this vector
     */
    public T magnitude() {
       return cast(T)sqrt(cast(double)(this.x * this.x + this.y * this.y));
    }

    public vec2!T asMagnitude(T val) {
        return this.unit * val;
    }

    /**
     * Formats this vector as a string of the form <x, y>
     * Returns: This vector represented as a string
     */
    public string toString() {
        return "<" ~ to!string(x) ~ ", " ~ to!string(y) ~ ">";
    }

    /**
     * Vector binary operations
     */
    public vec2!T opBinary(string op)(vec2!T rhs) if (op == "+" || op == "-" || op == "*") {
        if (op == "+" || op == "-") {
            return mixin("vec2f(this.x" ~ op ~ "rhs.x,this.y" ~ op ~ "rhs.y)");
        } else if (op == "*") { // dot product
            return this.x * rhs.x + this.y * rhs.y;
        }
    }

    /**
     * Computes the magnitude of the cross product of two vectors.
     * Params:
     *      rhs = The vector to take the cross product with
     * Returns:
     *      The magnitude of the cross product
     */
    public T cross(vec2!T rhs) {
        return this.x * rhs.y - this.y * rhs.x;
    }

    /**
     * Scalar operations - multiplication and division
     */
    public vec2!T opBinary(string op)(T n) if (op == "*" || op == "/") {
        return mixin("vec2!(T)(this.x" ~ op ~ "n,this.y" ~ op ~ "n)");
    }

}
