package com.vonage.tutorial.voice

import android.annotation.SuppressLint
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.nexmo.client.NexmoCall
import com.nexmo.client.NexmoCallHandler
import com.nexmo.client.NexmoClient
import com.nexmo.client.NexmoIncomingCallListener
import com.nexmo.client.request_listener.NexmoApiError
import com.nexmo.client.request_listener.NexmoRequestListener

class MainViewModel : ViewModel() {

    private val client = NexmoClient.get()
    private val callManager = CallManager
    private val navManager = NavManager

    private val _toast = MutableLiveData<String>()
    val toast = _toast as LiveData<String>

    private val _loading = MutableLiveData<Boolean>()
    val loading = _loading as LiveData<Boolean>

    private val incomingCallListener = NexmoIncomingCallListener { it ->
        callManager.onGoingCall = it
        val navDirections = MainFragmentDirections.actionMainFragmentToIncomingCallFragment()
        navManager.navigate(navDirections)
    }

    private val callListener = object : NexmoRequestListener<NexmoCall> {
        override fun onSuccess(call: NexmoCall?) {
            callManager.onGoingCall = call

            _loading.postValue(false)

            val navDirections = MainFragmentDirections.actionMainFragmentToOnCallFragment()
            navManager.navigate(navDirections)
        }

        override fun onError(apiError: NexmoApiError) {
            _toast.postValue(apiError.message)
            _loading.postValue(false)
        }
    }

    init {
        client.addIncomingCallListener(incomingCallListener)
    }

    override fun onCleared() {
        client.removeIncomingCallListeners()
    }

    @SuppressLint("MissingPermission")
    fun startAppToAppCall() {
        client.call("IGNORED", NexmoCallHandler.SERVER, callListener)
        _loading.postValue(true)
    }

    fun onBackPressed() {
        client.logout()
    }
}
