package com.vonage.tutorial.voice

import android.annotation.SuppressLint
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.nexmo.client.NexmoCall
import com.nexmo.client.request_listener.NexmoApiError
import com.nexmo.client.request_listener.NexmoRequestListener

class IncomingCallViewModel : ViewModel() {
    private val navManager: NavManager = NavManager
    private val callManager: CallManager = CallManager

    private val _toast = MutableLiveData<String>()
    var toast: LiveData<String> = _toast

    fun hangup() {
        hangupInternal(true)
    }

    @SuppressLint("MissingPermission")
    fun answer() {
        callManager.onGoingCall?.answer(object : NexmoRequestListener<NexmoCall?> {
            override fun onSuccess(call: NexmoCall?) {
                val navDirections = IncomingCallFragmentDirections.actionIncomingCallFragmentToOnCallFragment()
                navManager.navigate(navDirections)
            }

            override fun onError(apiError: NexmoApiError) {
                _toast.postValue(apiError.message)
            }
        })
    }

    fun onBackPressed() {
        hangupInternal(false)
    }

    private fun hangupInternal(popBackStack: Boolean?) {
        callManager.onGoingCall?.hangup(object : NexmoRequestListener<NexmoCall> {
            override fun onSuccess(call: NexmoCall?) {
                callManager.onGoingCall = null
            }

            override fun onError(apiError: NexmoApiError) {
                _toast.postValue(apiError.message)
            }
        })
    }
}