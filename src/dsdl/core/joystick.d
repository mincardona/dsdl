module dsdl.core.joystick;

import derelict.sdl2.sdl;
import std.string;

deprecated {

    class Joystick {
    // static

        private static Joystick[SDL_JoystickID] openSticks;

        public static Joystick byInstanceId(int id) {
            return openSticks.get(id, null);
        }

        @property {
            public static ref const(Joystick[SDL_JoystickID]) openJoysticks() {
                return openSticks;
            }
                
            /**
             * Tells the number of joystick devices connected to the system.
             * Returns: the number of joysticks
             */
            public static int howManyConnected() {
                return SDL_NumJoysticks();
            }
            
            /**
             * Tells the number of joystick devices currently open.
             * Returns: the number of joysticks
             */
            public static int howManyOpen() {
                return Joystick.openJoysticks.length;
            }
        }

        public static string getNameOfDevice(int index) {
            const char* name = SDL_JoystickNameForIndex(index);
            return fromStringz(name).idup;
        }

        public static void release(SDL_JoystickID id) {
            Joystick got = Joystick.byInstanceId(id);
            if (got !is null) {
                got.release();
                Joystick.openSticks.remove(id);
            }
        }
        
        public static void releaseAll() {
            auto keys = Joystick.openJoysticks.keys;
            foreach (key; keys) {
                Joystick.release(key);
            }
        }
        
        /**
         * Opens a Joysitck based on the given index and adds it to
         * the list of open sticks.
         * Params:
         *      index = the index of the device to open (different from instance id)
         * Returns: a new Joystick object, the existing object if the device was
         *          already open, or null on error
         */
        public static Joystick open(int index) {
            // create a new joystick and get the ID
            Joystick joy = new Joystick(index);
            auto id = joy.instanceId;
            
            if (id < 0) {
                return null;
            }
            
            // test if a joystick with the same ID is already in the array
            if ((id in Joystick.openSticks) == null) {
                Joystick.openSticks[id] = joy;
            } else {
                // two open joysticks have the same ID
                // it looks like these two joysticks will have the same
                // ptr handle (based on the docs), so just throw the new one away
                
                // assert(Joysticks.byInstanceId(id).ptr == joy.ptr);
                joy = Joystick.byInstanceId(id);
            }
            
            return joy;
        }

    // instance

        protected SDL_Joystick* stick;
        protected int _indexUsed;

        protected this(int index) {
            this._indexUsed = index;
            this.stick = SDL_JoystickOpen(index);
        }
        
        protected void release() {
            SDL_JoystickClose(stick);
        }
        
        @property {
            SDL_Joystick* ptr() {
                return stick;
            }
            
            SDL_JoystickID instanceId() {
                return SDL_JoystickInstanceID(this.ptr);
            }
            
            int indexUsed() {
                return this._indexUsed;
            }
        }
        
    }

}

