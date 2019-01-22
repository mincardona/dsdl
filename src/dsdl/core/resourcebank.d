module dsdl.core.resourcebank;

import dsdl.core.releaseable;

/**
 * A collection of resources associated with string identifiers.
 */
abstract class ResourceBank(T) : Releaseable
if (is(T : Releaseable))
{
    /** The inner associative array which matches string identifier keys to values of type T */
    protected T[string] resArray;

    /** Constructs an empty bank. */
    public this() {
        // nop
    }

    /**
     * Gets a resource from the bank using its identifier.
     * Throws: RangeError if the identifier is not found.
     */
    public T get(in string identifier) {
        return resArray[identifier];
    }

    /**
     * Gets a resource from the bank using its identifier.
     * If the identifier is not valid, returns some default value.
     * Params:
     *      identifier = identifier of the resource
     *      defaultValue = the value to return if the resource is not found
     * Returns: the resource, if found; otherwise, the default value
     */
    public T get(in string identifier, lazy T defaultValue) {
        return resArray.get(identifier, defaultValue);
    }

    /**
     * If the identifier is not already part of the collection, then adds the (identifier, resource) pair.
     * Params:
     *      identifier = the resource identifier
     *      resource = the resource to (possibly) add
     * Returns: true if the identifier was not already part of the collection; false otherwise
     */
    public bool add(in string identifier, T resource) {
        if (this.has(identifier)) {
            return false;
        }
        this.set(identifier, resource);
        return true;
    }

    /**
     * Adds a resource to this collection under a given identifier.
     * If the identifier already referred to a resource, that resource is discarded without being released.
     * Params:
     *      identifier = the resource identifier
     *      resource = the resource to add
     */
    public void set(in string identifier, T resource) {
        resArray[identifier] = resource;
    }

    /**
     * Adds a resource to this collection under a given identifier.
     * If the identifier already referred to a resource, that resource is released and discarded.
     * Params:
     *      identifier = the resource identifier
     *      resource = the resource to add
     */
    public void setAndRelease(in string identifier, T resource) {
        if (this.has(identifier)) {
            this.removeAndRelease(identifier);
        }
        this.set(identifier, resource);
    }

    /**
     * Determines whether a resource exists in this collection.
     * Params:
     *      identifier = the identifier to check
     * Returns: true if the identifier is present in this collection; false otherwise.
     */
    public bool has(in string identifier) {
        return (identifier in resArray) !is null;
    }

    /**
     * Removes a resource from this collection without releasing it.
     * Params:
     *      identifier = the identifier referring to the resource to remove
     * Returns: true if an extant resource was removed; false if no matching resource was found.
     */
    public bool remove(in string identifier) {
        return resArray.remove(identifier);
    }

    /**
     * Removes a resource from this collection after releasing it.
     * Params:
     *      identifier = the identifier referring to the resource to release and remove
     * Returns: true if an extant resource was removed; false if no matching resource was found.
     */
    public void removeAndRelease(in string identifier) {
        this.get(identifier).release();
        this.remove(identifier);
    }

    /**
     * Removes all resources from this collection without releasing them.
     */
    public void removeAll() {
        foreach (string key; resArray.keys) {
            this.remove(key);
        }
    }

    /**
     * Removes all resources from this collection after releasing them.
     */
    public void removeAllAndRelease() {
        foreach (string key; resArray.keys) {
            this.removeAndRelease(key);
        }
    }

    /**
     * Equivalent to removeAllAndRelease()
     */
    public void release() {
        this.removeAllAndRelease();
    }

    @property {
        /**
         * The number of (identifier, resource) pairs in this collection.
         */
        public size_t length() {
            return resArray.length;
        }
    }

}
