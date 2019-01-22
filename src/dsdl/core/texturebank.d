module dsdl.core.texturebank;

import dsdl.core.releaseable;
import dsdl.core.renderer;
import dsdl.core.resourcebank;
import dsdl.core.sdlutil;
import dsdl.core.texture;
import std.file;
import std.path;
import std.stdio;
import std.string;
import std.typecons;

/**
 * Format description:
 * # are line comments
 * <name_no_spaces> <path>
 */

/**
 * Relates identifiers to Texture objects in a collection format.
 * Authors: Michael Incardona
 */
class TextureBank : ResourceBank!Texture {

    public static immutable MISSING_TEXTURE = "";

    /**
     * Imports a collection of textures listed in a file. Textures which are already loaded (by identfier) are skipped.
     * If a texture cannot be located from the identifier in the file, the defaultExtension is applied.
     * Returns: A tuple of three integers: loaded (nof textures that are now loaded),
     *                                     skipped (nof textures that were already loaded),
     *                                     failed (nof textures that could not be loaded).
     */
    public auto importAll(in string listFile, string rootAssetDir, Renderer rend, string defaultExtension = "png") {
        string[] lns;
        getLines(listFile, lns);
        rootAssetDir = buildNormalizedPath(rootAssetDir);   // optimize the root path
        auto results = tuple!("loaded", "skipped", "failed")(0, 0, 0);  // return value

        // process each input line separately
        foreach (ref string line; lns) {
            // build the full path to the file
            string filePath = buildNormalizedPath(rootAssetDir, line);
            if (!isFileAndExists(filePath)) {
                // if the file isn't found, then the default extension is implied
                filePath ~= "." ~ defaultExtension;
                if (!isFileAndExists(filePath)) {
                    // file not found!
                    results.failed++;
                    continue;
                }
            }
            if (!this.has(line)) {
                // TODO: add handling for the case the the texture isn't loaded due to some i/o error
                Texture tex = new Texture(filePath, rend);
                this.set(line, tex);
                results.loaded++;
            } else {
                results.skipped++;
            }
        }
        return results;
    }

}
