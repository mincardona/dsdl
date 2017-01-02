module dsdl.core.grid2;

import dsdl.core.vec2;

/*
 * register event (triggered on calls to set())
 * unregister event
 */
// stored as a flat, row-major array by default
// y coords are flipped - 0 is upper-left
class grid2(T) {
    static alias setHandlerFn = void function(in grid2 g, in T old, int x, int y);
    static alias iterOverDelegate = void delegate(long x, long y, ref T cell);

    private T[] cells_;
    protected vec2L dimensions_;
    
    public vec2L hotspot;
    public setHandlerFn[] handlers_;
    
    public this(long width, long height) {
        dimensions_ = vec2L(width, height);
        hotspot = vec2L(0, 0);
        cells_ = new T[width * height];
    }
    
    @property {
        private pure T[] cells() {
            return cells_;
        }
        
        public pure long width() {
            return dimensions_.x;
        }
        
        public pure long height() {
            return dimensions._y;
        }
        
        public pure vec2L dimensions() {
            return dimensions_;
        }
        
        public pure long area() {
            return cells.length;
        }
    }
    
    // does no bounds checking
    protected pure long indexOfCoords(long x, long y) {
        return indexOfCoords(x, y, this.dimensions_, this.hotspot);
    }
    
    protected static pure long indexOfCoords(long x, long y, vec2L dim, vec2L hot) {
        return dim.x * (y - hot.y) + (x - hot.x);
    }
    
    // no bounds checking
    protected pure vec2L coordsOfIndex(long i) {
        return vec2L(
            (i % width) + hotspot.x,
            (i / width) + hotspot.y
        );
    }
    
    public final pure bool inRange(long x, long y) {
        return x >= hotspot.x && x < hotspot.x + width &&
               y >= hotspot.y && y < hotspot.y + height;
    }
    
    public final pure ref T get(long x, long y) {
        assert(inRange(x, y));
        return getRaw(x, y);
    }
    
    public final pure ref T getRaw(long x, long y) {
        return cells[indexOfCoords(x, y)];
    }
    
    public final void set(T val, long x, long y, bool bNotify = true) {
        assert(inRange(x, y));
        T old = setRawGet(val, x, y);
        if (bNotify) {
            notifyAll(old, x, y);
        }
    }
    
    public final T setRawGet(T val, long x, long y) {
        long index = indexOfCoords(x, y);
        T old = this.cells[index];
        this.cells[index] = val;
        return old;
    }
    
    public final void setRaw(T val, long x, long y) {
        this.cells[indexOfCoords(x, y)] = val;
    }
    
    // (x, y) is the corner with the minimum coordinates (min x and min y)
    public final void fillRect(T val, long x, long y, long w, long h, bool bNotify = true) {
        foreach (long yc; y..h) {
            foreach (long xc; x..w) {
                set(val, xc, yc, bNotify);
            }
        }
    }
    
    private final void notifyAll(const ref T old, long x, long y) {
        foreach (setHandlerFn fn; handlers_) {
            fn(this, old, x, y);
        }
    }
    
    public final T opIndex(long x, long y) {
        assert(inRange(x, y));
        return get(x, y);
    }
    
    public final T opIndexAssign(T val, long x, long y) {
        set(val, x, y);
        return val;
    }
    
    public final void iterOver(iterOverDelegate callme) {
        foreach (long x; hotspot.x .. dimensions.x - 1) {
            foreach (long y; hotspot.y .. dimensions.y - 1) {
                callme(x, y, getRaw(x, y));
            }
        }
    }
    
    public final void copyCellsTo(grid2 gother) {
        this.iterOver(
            delegate void(long x, long y, ref T cell) {
                if (gother.inRange(x, y)) {
                    gother.setRaw(getRaw(x, y), x, y);
                }
            }
        );
    }
    
    public void resize(in vec2L newHotspot, in vec2L newDims) {
        auto g = grid2!T(newDims.x, newDims.y);
        g.hotspot = newHotspot;
        this.copyCellsTo(g);
        this = g;
    }
    
    public void growRight(long n) {
        // change size by n * height
        assert(n >= 0);
        auto newDim = vec2L(width + n, height);
        resize(hotspot, newDim);
    }
    
    public void shrinkRight(long n) {
        assert(n >= 0 && n <= width);
        auto newDim = vec2L(width - n, height);
        resize(hotspot, newDim);
    }
    
    public void growLeft(long n) {
        assert(n >= 0);
        auto newDim = vec2L(width + n, height);
        auto newHotspot = vec2L(hotspot.x - n, hotspot.y);
        resize(newHotspot, newDim);
    }
    
    public void shrinkLeft(long n) {
        assert(n >= 0 && n <= width);
        auto newDim = vec2L(width - n, height);
        auto newHotspot = vec2L(hotspot.x + n, hotspot.y);
        resize(newHotspot, newDim);
    }
    
    public void growTop(long n) {
        assert(n >= 0 && n >= height);
        auto newDim = vec2L(width, height + n);
        auto newHotspot = vec2L(hotspot.x, hotspot.y - n);
        resize(newHotspot, newDim);
    }
    
    public void shrinkTop(long n) {
        assert(n >= 0 && n >= height);
        auto newDim = vec2L(width, height - n);
        auto newHotspot = vec2L(hotspot.x, hotspot.y + n);
        resize(newHotspot, newDim);
    }
    
    public void growBottom(long n) {
        assert(n >= 0);
        auto newDim = vec2L(width, height + n);
        resize(hotspot, newDim);
    }
    
    public void shrinkBottom(long n) {
        assert(n >= 0 && n <= width);
        auto newDim = vec2L(width, height - n);
        resize(hotspot, newDim);
    }
}
