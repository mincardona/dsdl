module dsdl.core.vec2f;

import std.math;
import std.conv;

/**
 * Represents a two-dimensional vector quantity.
 * Authors: Michael Incardona
 * TODO: optimize magnitude mutator
 */
struct vec2f {
    private double _x;
    private double _y;
    private double _magnitude;

    @disable this();

    /**
     * Creates a new 2D vector with the given component lengths
     * Params:
     *      x = the magnitude of the x component
     *      y = the magnitude of the y component
     */
    public this(double x, double y) {
        this._x = x;
        this._y = y;
        this._magnitude = computeMagnitude();
    }

    @property {
        /**
         * The magnitude of this vector
         */
        public double magnitude() {
           return _magnitude;
        }
        
        public double magnitude(double val) {
            this = this.unit * val;
            return this.magnitude;
        }
    }

    /**
     * Computes a unit vector (vector of magnitude 1) which points in
     *      the same direction as this vector
     */
    public vec2f unit() {
        return this / this.magnitude;
    }

    /**
     * The x component of this vector
     */
    @property public double x() {
        return _x;
    }

    /**
     * The y component of this vector
     */
    @property public double y() {
        return _y;
    }

    /**
     * The x component of this vector
     */
    @property public double x(double value) {
        this._x = value;
        this._magnitude = computeMagnitude();
        return x;
    }

    /**
     * The y component of this vector
     */
    @property public double y(double value) {
        this._y = value;
        this._magnitude = computeMagnitude();
        return y;
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
    public vec2f opBinary(string op)(vec2f rhs) if (op == "+" || op == "-" || op == "*") {
        if (op == "+" || op == "-")
            return mixin("vec2f(this.x" ~ op ~ "rhs.x,this.y" ~ op ~ "rhs.y)");
        else if (op == "*") // dot product
            return this.x * rhs.x + this.y * rhs.y;
    }

    /**
     * Computes the magnitude of the cross product of two vectors.
     * Params:
     *      rhs = The vector to take the cross product with
     * Returns:
     *      The magnitude of the cross product
     */
    public double cross(vec2f rhs) {
        return this.x * rhs.y - this.y * rhs.x;
    }

    /**
     * Scalar operations - multiplication and division
     */
    public vec2f opBinary(string op)(double n) if (op == "*" || op == "/") {
        return mixin("vec2f(this.x" ~ op ~ "n,this.y" ~ op ~ "n)");
    }

    /**
     * Computes the magnitude (length) of this vector
     */
    private double computeMagnitude() {
        return sqrt(this.x * this.x + this.y * this.y);
    }

}

