module dsdl.core.sprite;

import dsdl.core.texture;
import dsdl.core.clock;
import dsdl.core.texturebank;

/**
 * An animated texture sequence
 * Authors: Michael Incardona
 */
class Sprite {
    private int[] durs;     // duration of each frame in micros
    private string[] ids;   // id of each texture
    private int _length;    // length of whole animation - sum of ids[]
    private Clock _timer;

    public this(string[] names, int[] durations) {
        assert(names.length == durations.length);
        this.ids = names.dup;
        this.durs = durations.dup;
        this._length = 0;
        foreach (int i; this.durs) {
            this._length += i;
        }
        this._timer = new Clock();
    }

    @property public Clock sequence() {
        return _timer;
    }

    @property public int length() {
        return _length;
    }

    public string getTextureName() {
        ulong time = sequence.checkMicros() % length;
        int accum = 0;
        for (int i = 0; i < durs.length; i++) {
            if ((accum += durs[i]) > time) {
                return ids[i];
            }
        }
        // shouldn't be reached unless this.length is incorrect
        return TextureBank.MISSING_TEXTURE;
    }

    public int getFrameDuration(int i) {
        if (i < 0 || i >= durs.length) {
            return -1;
        }
        return durs[i];
    }

    public string getFrameTextureName(int i) {
        if (i < 0 || i >= ids.length) {
            return TextureBank.MISSING_TEXTURE;
        }
        return ids[i];
    }
}
