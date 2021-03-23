package com.vonage.tutorial.voice

import android.os.Bundle
import android.view.View
import android.widget.Button
import android.widget.ProgressBar
import android.widget.TextView
import android.widget.Toast
import androidx.core.view.isVisible
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import androidx.lifecycle.Observer
import com.nexmo.client.request_listener.NexmoConnectionListener.ConnectionStatus
import kotlin.properties.Delegates

class LoginFragment : Fragment(R.layout.fragment_login) {

    private val viewModel by viewModels<LoginViewModel>()

    private lateinit var loginAsAliceButton: Button
    private lateinit var loginAsBobButton: Button
    private lateinit var progressBar: ProgressBar
    private lateinit var connectionStatusTextView: TextView

    private var dataLoading: Boolean by Delegates.observable(false) { _, _, newValue ->
        loginAsAliceButton.isEnabled = !newValue
        loginAsBobButton.isEnabled = !newValue
        progressBar.isVisible = newValue
    }

    private val stateObserver = Observer<ConnectionStatus> {
        connectionStatusTextView.text = it.toString()

        if (it == ConnectionStatus.DISCONNECTED) {
            dataLoading = false
        }
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        viewModel.connectionStatus.observe(viewLifecycleOwner, stateObserver)

        loginAsAliceButton = view.findViewById(R.id.loginAsAliceButton)
        loginAsBobButton = view.findViewById(R.id.loginAsBobButton)
        progressBar = view.findViewById(R.id.progressBar)
        connectionStatusTextView = view.findViewById(R.id.connectionStatusTextView)

        loginAsAliceButton.setOnClickListener {
            loginUser(Config.alice)
        }

        loginAsBobButton.setOnClickListener {
            loginUser(Config.bob)
        }
    }

    private fun loginUser(user: User) {
        if (user.jwt.isBlank()) {
            Toast.makeText(context, "Error: Please set Config.${user.name.toLowerCase()}.jwt", Toast.LENGTH_SHORT).show()
        } else {
            viewModel.onLoginUser(user)
            dataLoading = true
        }
    }
}
