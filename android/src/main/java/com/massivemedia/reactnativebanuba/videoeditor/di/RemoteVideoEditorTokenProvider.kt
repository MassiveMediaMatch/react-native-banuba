package com.banuba.example.integrationapp.videoeditor.di

import android.util.Log
import com.banuba.sdk.token.storage.TokenProvider

class RemoteVideoEditorTokenProvider : TokenProvider {
    override fun getToken(): String {
// Return your video editor token here
        Log.w("token", "got RemoteVideoEditorTokenProvider")
        return "j468B3S38YMa1ggmVlk+eixK7fK+1u0DuoAruXXiLp1kBNVx3itLv94Te1eVTAjYzgLTORexzjBxlPY0eq222mdxQPF+iLqgmVpWrC4lBXiEByrb5VpUqsFxaM/K9LLWDiI0bdQWeTy8YYulKgmPXrY="
    }
}