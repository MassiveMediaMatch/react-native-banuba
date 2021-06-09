package com.banuba.example.integrationapp.videoeditor.di

import android.content.Context
import android.util.Log
import com.banuba.sdk.token.storage.provider.TokenProvider

class RemoteVideoEditorTokenProvider(private val androidContext: Context) : TokenProvider {
    override fun getToken(): String {
        val sharedPref = androidContext.getSharedPreferences("banuba", Context.MODE_PRIVATE)
        val token = sharedPref.getString("banuba_video_editor_token", "")
        return token!!
      }
}