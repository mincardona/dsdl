module dsdl.core.releaseable;

/**
 * Represents an object that must manually free allocated resources before being garbage collected.
 * Authors: Michael Incardona
 */
interface Releaseable {
    /**
     * Frees any resources allocated by this object that the garbage collector would not touch.
     */
    abstract public void release();
}

