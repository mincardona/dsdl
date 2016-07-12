module dsdl.core.clock;

import derelict.sdl2.sdl;
import dsdl.core.sdlutil;

/**
 * A clock used to record time.
 * Authors: Michael Incardona
 */
class Clock {
	/** (performance ticks) accumulated time before last pause */
	private ulong storedTime;
	/** (performance ticks) time to count from */
	private ulong startTime;
	/** true if this timer is currently accumulating time */
	private bool _isRunning;

    /**
     * Initializes this clock to a paused state with 0 recorded time.
     */
	public this() {
		storedTime = 0;
		_isRunning = false;
	}

	/**
	 * true if this clock is currently recording time
	 */
	public @property bool isRunning() {
	    return _isRunning;
	}

	/**
	 * Begins time accumulation, without erasing accumulated time.
	 */
	public void go() {
		if (isRunning)
			return;
		startTime = SDL_GetPerformanceCounter();
		_isRunning = true;
	}

	/**
	 * Pauses time accumulation, without erasing accumulated time.
	 */
	public void pause() {
		if (!isRunning)
			return;
		storedTime += SDL_GetPerformanceCounter() - startTime;
		_isRunning = false;
	}

	/** Resets the timer to 0. This function does not affect whether the timer is running. */
	public void reset() {
		storedTime = 0;
		startTime = SDL_GetPerformanceCounter();
	}

	/**
	 * Check microseconds recorded by the timer.
	 * Returns: microseconds accumulated by this timer
	 */
	public ulong checkMicros() {
		if (isRunning)
			return microsPassed(startTime, SDL_GetPerformanceCounter() + storedTime);
		else
			return microsPassed(0, storedTime);
	}

	/**
	 * Check milliseconds recorded by the timer.
	 * Returns: milliseconds accumulated by this timer
	 */
	public ulong checkMillis() {
		if (isRunning)
			return millisPassed(startTime, SDL_GetPerformanceCounter() + storedTime);
		else
			return millisPassed(0, storedTime);
	}

	/**
	 * Check seconds recorded by the timer.
	 * Returns: seconds accumulated by this timer
	 */
	public ulong checkSeconds() {
		if (isRunning)
			return secondsPassed(startTime, SDL_GetPerformanceCounter() + storedTime);
		else
			return secondsPassed(0, storedTime);
	}
	
	/**
	 * Check ticks recorded by the timer.
	 * Returns: ticks accumulated by this timer
	 */
	public ulong checkTicks() {
	    if (isRunning)
	        return ticksPassed(startTime, SDL_GetPerformanceCounter() + storedTime);
	    else
	        return ticksPassed(0, storedTime);
	}

	/**
	 * Pauses the timer and erases accumulated time.
	 * Equivalent to calling pause() followed by reset()
	 */
	public void stop() {
		pause();
		reset();
	}

	/**
	 * Computes the number of microseconds that passed between two performance tick values.
     * Params:
     *      perfTicks1 = the initial performance tick
     *      perfTicks2 = the final performance tick
     * Returns: The duration in microseconds (truncated)
	 */
	public static ulong microsPassed(ulong perfTicks1, ulong perfTicks2) {
		return (perfTicks2 - perfTicks1) * MICROS_PER_S / SDL_GetPerformanceFrequency();
	}

	/**
	 * Computes the number of milliseconds that passed between two performance tick values.
     * Params:
     *      perfTicks1 = the initial performance tick
     *      perfTicks2 = the final performance tick
     * Returns: The duration in milliseconds (truncated)
	 */
	public static ulong millisPassed(ulong perfTicks1, ulong perfTicks2) {
		return (perfTicks2 - perfTicks1) * MS_PER_S / SDL_GetPerformanceFrequency();
	}

	/**
	 * Computes the number of seconds that passed between two performance tick values.
     * Params:
     *      perfTicks1 = the initial performance tick
     *      perfTicks2 = the final performance tick
     * Returns: The duration in seconds (truncated)
	 */
	public static ulong secondsPassed(ulong perfTicks1, ulong perfTicks2) {
		return (perfTicks2 - perfTicks1) / SDL_GetPerformanceFrequency();
	}
	
	public static ulong ticksPassed(ulong perfTicks1, ulong perfTicks2) {
	    return perfTicks2 - perfTicks1;
	}
	
	public static ulong tickFrequency() {
	    return SDL_GetPerformanceFrequency();
	}
}
