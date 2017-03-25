module dsdl.mixer.soundbank;

import dsdl.mixer.soundchunk;
import dsdl.core.sdlutil;
import std.stdio;
import std.string;
import dsdl.core.releaseable;
import dsdl.core.resourcebank;

/**
 * Relates identifiers to SoundChunk objects in a collection format.
 * Authors: Michael Incardona
 */
class SoundBank : ResourceBank!SoundChunk {

    public static immutable MISSING_SOUND = "";

    public void importAllChunks(string chunkListFile, string rootAssetDir) {
        string[] lns;
        try {
            getLines(chunkListFile, lns);
        } catch (StdioException e) {
            sdlLogger.errorf("Unable to import SoundChunks from \"%s\": %s", chunkListFile, e.msg);
            return;
        }
        foreach (ref string line; lns) {
            uint indexOfSpace = indexOfAny(line, " \t");
            if (indexOfSpace == -1 || indexOfSpace == line.length)
                throw new DataFormatException("Unable to parse file \"" ~ chunkListFile ~ "\"");
            string chunkName = line[0..indexOfSpace];
            if (!this.has(chunkName)) {
                string chunkPath = rootAssetDir ~ line[indexOfSpace + 1 .. $];
                this.add(chunkName, new SoundChunk(chunkPath));
            }
        }
    }

}

