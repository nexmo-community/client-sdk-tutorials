package com.vonage.tutorial.voice

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.navigation.NavDirections
import com.nexmo.client.NexmoClient
import com.nexmo.client.request_listener.NexmoConnectionListener.ConnectionStatus

class LoginViewModel : ViewModel() {

    private val navManager = NavManager

    private var user: User? = null

    private val _connectionStatus = MutableLiveData<ConnectionStatus>()
    val connectionStatus = _connectionStatus as LiveData<ConnectionStatus>

    private val client = NexmoClient.get()

    init {
        client.setConnectionListener { newConnectionStatus, _ ->

            if (newConnectionStatus == ConnectionStatus.CONNECTED) {

                user?.let {
                    val navDirections = LoginFragmentDirections.actionLoginFragmentToMainFragment(it.name)
                    navManager.navigate(navDirections)
                }

                return@setConnectionListener
            }

            _connectionStatus.postValue(newConnectionStatus)
        }
    }

    fun onLoginUser(user: User) {
        this.user = user;

        if (user.jwt.isNotBlank()) {
            client.login(user.jwt)
        }
    }
}
