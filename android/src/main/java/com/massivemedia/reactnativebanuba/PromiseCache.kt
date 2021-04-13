package com.massivemedia.reactnativebanuba

import android.util.Log
import com.facebook.react.bridge.Promise

class PromiseCache {
    val LOG_TAG = "BanubaPromises" + PromiseCache::class.java.simpleName

    var promiseCache = HashMap<String, Promise?>()

    @Synchronized
    fun resolvePromise(key: String, value: Any) {
        if (promiseCache.containsKey(key)) {
            val promise = promiseCache[key]
            promise!!.resolve(value)
            promiseCache.remove(key)
        } else {
            Log.w(LOG_TAG, String.format("Tried to resolve promise: %s - but does not exist in cache", key))
        }
    }

    @Synchronized
    fun rejectPromise(key: String, reason: String) {
        if (promiseCache.containsKey(key)) {
            val promise = promiseCache[key]
            promise!!.reject("EUNSPECIFIED", reason)
            promiseCache.remove(key)
        } else {
            Log.w(LOG_TAG, String.format("Tried to reject promise: %s - but does not exist in cache", key))
        }
    }

    @Synchronized
    fun putPromise(key: String, promise: Promise) {
        promiseCache[key] = promise
    }

    @Synchronized
    fun hasPromise(key: String): Boolean {
        return promiseCache.containsKey(key)
    }

    @Synchronized
    fun clearPromises() {
        promiseCache.clear()
    }
}