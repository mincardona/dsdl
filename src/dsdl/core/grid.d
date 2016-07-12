module dsdl.core.grid;

import std.conv;
import std.string;

/**
 * A two-dimensional, resizeable grid collection.
 * Authors: Michael Incardona
 */
class Grid(T) {
    // stored row by row
    private T[] _elements;
    private int _width;
    private int _height;
    private int _area;
    
    /**
     * Intializes this grid with specified dimensions and fills it with a specified value.
     * Params:
     *      wid = the width of this grid
     *      hgt = the height of this grid
     *      fill = the value to fill the grid with
     */
    public this(int wid, int hgt, T fill) {
        _width = wid;
        _height = hgt;
        _elements.length = width * height;
        for (int i = 0; i < _elements.length; i++)
            _elements[i] = fill;
    }
    
    /**
     * Gets an element from the grid.
     * Params:
     *      x = the x coordinate of the element to get
     *      y = the y coordinate of the element to get
     * Returns: The element at (x, y) in the grid
     */
    public T get(int x, int y) {
        return _elements[collapse(x, y)];
    }
    
    /**
     * Gets an element from the grid.
     * Params:
     *      i = the index of the element to get
     * Returns: The element at [i] in the grid
     */
    public T get(int i) {
        return _elements[i];
    }
    
    /**
     * Puts an element in the grid.
     * Params:
     *      x = the x coordinate of the target location
     *      y = the y coordinate of the target location
     *      val = the value to place in the grid
     * Returns: The element placed in the grid
     */
    public T set(int x, int y, T val) {
        return (_elements[collapse(x, y)] = val);
    }
    
    /**
     * Puts an element in the grid.
     * Params:
     *      i = the index of the target location
     *      val = the element to place in the grid
     * Returns: the element placed in the grid
     */
    public T set(int i, T val) {
        return (_elements[i] = val);
    }
    
    /**
     * Fills the grid with a specified value.
     * Params:
     *      val = the value to fill the grid with
     */
    public void fill(T val) {
        for (int i = 0; i < area; i++)
            _elements[i] = val;
    }
    
    /**
     * Adds columns to the left side of this grid.
     * Params:
     *      n = the number of columns to add (n >= 0)
     *      fill = the value to fill new spaces with
     */
    // lazy implementation
    public void addColumnsLeft(int n, T fill) {
        // assert(n >= 0)
        if (n == 0)
            return;
        // we will copy to a new array
        T[] newelems;
        // allocate this many *additional* spaces
        int newMem = n * height;
        int newWidth = n + width;
        newelems.length = _elements.length + newMem;
        // copy elements from old to new location
        for (int x = 0; x < width; x++)
            for (int y = 0; y < height; y++)
                newelems[y * newWidth + x + n] = this.get(x, y);
        // fill in empty columns
        for (int x = 0; x < n; x++)
            for (int y = 0; y < height; y++)
                newelems[x + y * newWidth] = fill;
        // update width and array pointer
        width = newWidth;
        _elements = newelems;
    }
    
    /**
     * Adds columns to the right side of this grid.
     * Params:
     *      n = the number of columns to add (n >= 0)
     *      fill = the value to fill new spaces with
     */
    // lazy implementation
    public void addColumnsRight(int n, T fill) {
        // assert(n >= 0)
        if (n == 0)
            return;
        // we will copy to a new array
        T[] newelems;
        // allocate this many *additional* spaces
        int newMem = n * height;
        int newWidth = n + width;
        newelems.length = _elements.length + newMem;
        // copy elements from old to new location
        for (int x = 0; x < width; x++)
            for (int y = 0; y < height; y++)
                newelems[y * newWidth + x] = this.get(x, y);
        // fill in empty columns
        for (int x = width; x < width + n; x++)
            for (int y = 0; y < height; y++)
                newelems[x + y * newWidth] = fill;
        // update width and array pointer
        width = newWidth;
        _elements = newelems;
    }
    
    /**
     * Adds rows to the top of this grid.
     * Params:
     *      n = the number of rows to add (n >= 0)
     *      fill = the value to fill new spaces with
     */
    // not lazy!
    public void addRowsTop(int n, T fill) {
        // assert(n >= 0);
        if (n == 0)
            return;
        // allocate this many additional spaces
        int newMem = width * n;
        _elements.length += newMem;
        // copy each element newMem spaces forward in the array
        for (int i = _elements.length-1; i >= newMem; i--)
            _elements[i] = _elements[i - newMem];
        for (int i = 0; i < newMem; i++)
            _elements[i] = fill;
        height = height + n;
    }
    
    /**
     * Adds rows to the bottom of this grid.
     * Params:
     *      n = the number of rows to add (n >= 0)
     *      fill = the value to fill new spaces with
     */
    // not lazy
    public void addRowsBottom(int n, T fill) {
        // assert(n >= 0);
        if (n == 0)
            return;
        // allocate this many additional spaces
        int newMem = width * n;
        int oldArea = _elements.length;
        _elements.length += newMem;
        // copy each element newMem spaces forward in the array
        for (int i = _elements.length-1; i >= oldArea; i--)
            _elements[i] = fill;
        height = height + n;
    }
    
    @property {
        /** The area of this grid. */
        public int area() { return _elements.length; }
        /** The width of this grid. */
        public int width() { return _width; }
        protected int width(int val) { return (_width = val); }
        /** The height of this grid. */
        public int height() { return _height; }
        protected int height(int val) { return (_height = val); }
    }
    
    /**
     * Translates element coordinates into a grid index.
     * Params:
     *      x = x coordinate
     *      y = y coordinate
     * Returns: index corresponding to the given coordinates
     */
    public int collapse(int x, int y) {
        return y * _width + x;
    }
    
    /**
     * Represents the grid from left to right, then top to bottom,
     *  with each element on its own line. Rows are separated with lines, 
     *  and the whole grid is surrounded by separators describing its area.
     * Returns: the string representation of this grid
     */
    // linear representation
    override public string toString() {
        string ret = format("<grid area=%d>\n", area);
        for (int y = 0; y < height; y++) {
            ret ~= "<row " ~ to!string(y) ~ ">\n";
            for (int x = 0; x < width; x++) {
                ret ~= to!string(get(x, y)) ~ "\n";
            }
        }
        return ret ~ "</grid>";
    }
}
