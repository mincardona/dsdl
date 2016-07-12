module dsdl.mixer.musicchunk;

import derelict.sdl2.sdl;
import derelict.sdl2.mixer;
import std.string;
import dsdl.core.releaseable;

/**
 * Encapsulates a sound as a piece of music.
 * Authors: Michael Incardona
 */
class MusicChunk : Releaseable {
    private Mix_Music* music;

    /**
     * Initializes this object with the given music chunk.
     */
    public this(Mix_Music* music) {
        this.music = music;
    }

    // This can load WAVE, MOD, MIDI, OGG, MP3, FLAC, and
    //      any file that you use a command to play with.
    // File types must be initialized with initSDLMixer() (except WAVE & ?)
    /**
     * Initializes this object with music from the specified sound file.
     * Note that the file format must have been initialized with initSDLMixer()
     * Params:
     *      fileName = name of the music file to laod from
     */
    public this(string fileName) {
        this(Mix_LoadMUS(toStringz(fileName)));
    }

    @property {
        /** Pointer to the underlying Mix_Music */
        public Mix_Music* ptr() { return music; }
    }

    override public void release() {
        Mix_FreeMusic(music);
        music = null;
    }

    public bool checkIntegrity() {
        return music !is null;
    }

}
