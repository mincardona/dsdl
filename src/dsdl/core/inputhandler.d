module dsdl.core.inputhandler;

import derelict.sdl2.sdl;

/**
 * An object that can handle keyboard and mouse input.
 * Authors: Michael Incardona
 */
interface InputHandler {
    /**
     * Processes the depression of a key on the keyboard.
     * Params:
     *      event = struct containing information about the key event
     */
	abstract public void processKeyDown(SDL_KeyboardEvent event);
	
	/**
     * Processes the release of a key on the keyboard.
     * Params:
     *      event = struct containing information about the key event
     */
	abstract public void processKeyUp(SDL_KeyboardEvent event);
	
	/**
     * Processes the depression of a button on the mouse.
     * Params:
     *      event = struct containing information about the mouse button event
     */
	abstract public void processMouseButtonDown(SDL_MouseButtonEvent event);
	
	/**
     * Processes the release of a button on the mouse.
     * Params:
     *      event = struct containing information about the mouse button event
     */
	abstract public void processMouseButtonUp(SDL_MouseButtonEvent event);
	
	/**
     * Processes movement of the mouse.
     * Params:
     *      event = struct containing information about the mouse motion event
     */
	abstract public void processMouseMotion(SDL_MouseMotionEvent event);
	
	/**
     * Processes movement of the mouse wheel.
     * Params:
     *      event = struct containing information about the mouse wheel motion event
     */
	abstract public void processMouseWheelUse(SDL_MouseWheelEvent event);
}
