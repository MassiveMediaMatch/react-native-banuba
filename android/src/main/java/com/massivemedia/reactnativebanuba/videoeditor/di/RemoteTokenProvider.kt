package com.massivemedia.reactnativebanuba.videoeditor.di
import android.content.Context
import android.util.Log
import com.banuba.sdk.token.storage.TokenProvider
import com.massivemedia.reactnativebanuba.R
class RemoteTokenProvider (): TokenProvider {
    override fun getToken (): String {
        Log.w("token", "get token(effect_player_token)")
        return "U5n/CVWBj5pHv/5x5zTi/TRKfEC8pkAjGbiOTzWJ90KZtVbb8BITNW7JE/6+DPR+qq9SaEroNrkxQjb7SUWmQvIyho/HXeSTEt0qKPjW0GNNn+kjd3GIjy/nzUjIjLL5TEDiP6FTs40a2RyWCjMNQFW/2hJ6TvFewZGjnZ/Rv1B6dmEfUXb+fUWSYAbbF6ocDLtoOfE/5pjAaZithT6Qdw0+OwitDKi8ERrDijqavQuwIr8cw4rpGM5d58UflXThy2kouLMTw5quuKs/r/rUhIdU1T13sG5i1szNnvd1011QUk7NwpFZTpF93B2M5JcYP1CQDJz09XodxrbXBXrKIvFIkZTmyUBVWlAaxDPM3WFlYAoxx3P0xBtinLQ9K0s1AMcpvgy8jmnh7JXUQQIcNrYj36O9HN+fFxt+vaVLMYF4vV9LwxCW2JPDcF5zJ8+CdQmJ/foDVu3uNZshv0VtgJf3oRkups2h1WwJd6Riqw3m5gIsV3Xfdj8JmrpZ9wRXBjVZV9k86Fe+BYHPzyuNZ+PPfCRsYTwMZtB5Inn7SVH/Dc/4sg3ypjfR4lHI40pyO4s7/DaS5BPoddH8LHgGl29VNfZ+YsWvbB5HUIMtm77PezU7xIBrVtxH/SusMHAQJQ/l0vdTDGKHj/gTwns2yZW3gph+0WFXR6wbvsYg6Poi"
    }
}