package com.banuba.example.integrationapp.videoeditor.di

import android.content.Context
import android.util.Log
import com.banuba.sdk.token.storage.TokenProvider

class RemoteFaceArTokenProvider(private val androidContext: Context) : TokenProvider {
    override fun getToken(): String {
        val sharedPref = androidContext.getSharedPreferences("banuba",Context.MODE_PRIVATE)
        val token = sharedPref.getString("banuba_effect_token", "")
        return token!!
    }
}