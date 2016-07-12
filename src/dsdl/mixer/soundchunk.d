module dsdl.mixer.soundchunk;

import derelict.sdl2.sdl;
import derelict.sdl2.mixer;
import std.string;
import dsdl.core.releaseable;

/**
 * A sound effect.
 * Authors: Michael Incardona
 */
class SoundChunk : Releaseable {
    private Mix_Chunk* chunk;

    public this(Mix_Chunk* chunk) {
        this.chunk = chunk;
    }

    // This can load WAVE, AIFF, RIFF, OGG, and VOC files
    public this(string filePath) {
        this(Mix_LoadWAV(toStringz(filePath)));
    }

    @property {
        public Mix_Chunk* ptr() { return chunk; }
    }

    override public void release() {
        Mix_FreeChunk(chunk);
        chunk = null;
    }

    public bool checkIntegrity() {
        return chunk !is null;
    }
}
