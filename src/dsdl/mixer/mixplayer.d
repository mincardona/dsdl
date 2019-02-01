module dsdl.mixer.mixplayer;

import derelict.sdl2.sdl;
import derelict.sdl2.mixer;
import dsdl.mixer.soundchunk;
import dsdl.mixer.musicchunk;
import dsdl.core.sdlutil;
import dsdl.core.error;
import dsdl.mixer.error;
import std.algorithm.comparison;

/**
 * Contains fucntions for playing music and sound effects.
 * TODO: Mix_FadingMusic(), channel status functions
 * Authors: Michael Incardona
 */
final class MixPlayer {

    private this() {}

    @property {
        /** true if music is being played. */
        bool playingMusic() { return Mix_PlayingMusic() != 0; }
        /** true if music is paused */
        bool pausedMusic() { return Mix_PausedMusic() != 0; }
    }

    /**
     * Plays a sound once on the first open channel.
     * Params:
     *      s = the sound to play
     *      volume = the volume to play the song at
     * Return: The channel the sound was played on
     */
    public static int playSound(SoundChunk s, int volume) {
        int chan = Mix_PlayChannel(-1, s.ptr, 0); //play the sound once on the first open channel
        setChannelVolume(chan, volume);
        return chan;
    }

    public static void setChannelVolume(int chan, int volume) {
        Mix_Volume(chan, clamp(volume, -1, MIX_MAX_VOLUME));
    }

    /**
     * Plays music.
     * Params:
     *      m = the music to play
     *      volume = the volume to play the music at
     *      loops = the number of times to loop the music (default is -1, which indicates infinite loop)
     */
    public static void playMusic(MusicChunk m, int volume, int loops = -1) {
        sdlEnforceZero!sdlMixerException(Mix_PlayMusic(m.ptr, loops));
        setMusicVolume(volume);
    }

    /**
     * Pauses the music playing.
     */
    public static void pauseMusic() {
        Mix_PauseMusic();
    }

    /**
     * Fully stops the music which is playing.
     */
    public static void haltMusic() {
        Mix_HaltMusic();
    }

    /**
     * Resumes music playback, if it was paused.
     */
    public static void resumeMusic() {
        Mix_ResumeMusic();
    }

    /**
     * Restarts the music currently playing.
     */
    public static void rewindMusic() {
        Mix_RewindMusic();
    }

    /**
     * Sets the position of the currently playing music.
     * Params:
     *      pos = the position to set. This value has different meanings depending on the music format.
     */
    public static void setMusicPosition(double pos) {
        Mix_SetMusicPosition(pos);
    }

    /**
     * Fades out the currently playing music. This function decreses the volume over time, then halts playback.
     * Params:
     *      ms = The time over which to fade out the music, in milliseconds
     */
    public static void fadeOutMusic(int ms) {
        Mix_FadeOutMusic(ms);
    }

    public static void fadeInMusicPos(
                            MusicChunk m, int ms, double pos, int volume, int loops = -1) {
        Mix_FadeInMusicPos(m.ptr, loops, ms, pos);
        setMusicVolume(volume);
    }

    public static void fadeInMusic(MusicChunk m, int ms, int volume, int loops = -1) {
        fadeInMusicPos(m, ms, 0, volume, loops);
    }

    /**
     * Sets the volume of the music currently playing.
     * Params:
     *      volume = the volume to play music at (-1-MIX_MAX_VOLUME)
     */
    public static void setMusicVolume(int volume) {
        Mix_VolumeMusic(clamp(volume, -1, MIX_MAX_VOLUME));
    }

    /**
     * Specifies a callback function to be played when music finishes playback.
     *
     * NEVER call SDL_Mixer (MixPlayer) functions, nor SDL_LockAudio (LockAudio), from a callback function.
     *
     * Params:
     *      call = the function to call
     */
    public static void hookMusicFinished(MixPlayerCallback call) {
        Mix_HookMusicFinished(call);
    }

    /**
     * Pauses the sound playing on a channel.
     * Params:
     *      channel = the channel to pause. Default is -1, or the first open channel
     */
    public static void pause(int channel = -1) {
        Mix_Pause(channel);
    }

    /**
     * Allocates channels until a given number of channels exist.
     * Params:
     *      nChannels = the number of channels that should exist, in total
     */
    public static int allocateChannels(int nChannels) {
        return Mix_AllocateChannels(nChannels);
    }

}

enum FadingStatus {
    NOT_FADING = MIX_NO_FADING,
    FADING_IN = MIX_FADING_IN,
    FADING_OUT = MIX_FADING_OUT
}
