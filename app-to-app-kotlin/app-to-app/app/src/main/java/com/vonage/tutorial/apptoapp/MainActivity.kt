package com.vonage.tutorial.apptoapp

import android.Manifest
import android.annotation.SuppressLint
import android.os.Bundle
import android.view.View
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import androidx.core.app.ActivityCompat
import androidx.core.view.forEach
import com.vonage.voice.api.*

class MainActivity : AppCompatActivity() {

    private val aliceJWT = ""
    private val bobJWT = ""
    private lateinit var client: VoiceClient
    private var otherUser: String = ""
    private var onGoingCall: VoiceCall? = null
    private var callInvite: VoiceInvite? = null

    private lateinit var connectionStatusTextView: TextView
    private lateinit var waitingForIncomingCallTextView: TextView
    private lateinit var loginAsAlice: Button
    private lateinit var loginAsBob: Button
    private lateinit var startCallButton: Button
    private lateinit var answerCallButton: Button
    private lateinit var rejectCallButton: Button
    private lateinit var endCallButton: Button

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        // request permissions
        val callsPermissions = arrayOf(Manifest.permission.RECORD_AUDIO)
        ActivityCompat.requestPermissions(this, callsPermissions, 123)

        // init views
        connectionStatusTextView = findViewById(R.id.connectionStatusTextView)
        waitingForIncomingCallTextView = findViewById(R.id.waitingForIncomingCallTextView)
        loginAsAlice = findViewById(R.id.loginAsAlice)
        loginAsBob = findViewById(R.id.loginAsBob)
        startCallButton = findViewById(R.id.startCallButton)
        answerCallButton = findViewById(R.id.answerCallButton)
        rejectCallButton = findViewById(R.id.rejectCallButton)
        endCallButton = findViewById(R.id.endCallButton)

        loginAsAlice.setOnClickListener { loginAsAlice() }
        loginAsBob.setOnClickListener { loginAsBob() }
        answerCallButton.setOnClickListener { answerCall() }
        rejectCallButton.setOnClickListener { rejectCall() }
        endCallButton.setOnClickListener { endCall() }
        startCallButton.setOnClickListener { startCall() }

        client = VoiceClient(this.application.applicationContext)
        client.setConfig(ClientConfig(ConfigRegion.US))

        client.setCallInviteListener { invite ->
            callInvite = invite
            runOnUiThread {
                hideUI()
                answerCallButton.visibility = View.VISIBLE
                rejectCallButton.visibility = View.VISIBLE
            }
        }
    }

    private fun hideUI() {
        val content = findViewById<LinearLayout>(R.id.content)
        content.forEach { it.visibility = View.GONE }
    }

    private fun loginAsAlice() {
        otherUser = "Bob"
        client.createSession(aliceJWT, null) {
                err, sessionId ->
            when {
                err != null -> {
                    hideUI()
                    connectionStatusTextView.visibility = View.VISIBLE
                    connectionStatusTextView.text = err.localizedMessage
                }
                else -> {
                    hideUI()
                    connectionStatusTextView.visibility = View.VISIBLE
                    connectionStatusTextView.text = "Connected"
                    startCallButton.visibility = View.VISIBLE
                    waitingForIncomingCallTextView.visibility = View.VISIBLE
                }
            }
        }
    }

    private fun loginAsBob() {
        otherUser = "Alice"
        client.createSession(bobJWT, null) {
                err, sessionId ->
            when {
                err != null -> {
                    hideUI()
                    connectionStatusTextView.visibility = View.VISIBLE
                    connectionStatusTextView.text = err.localizedMessage
                }
                else -> {
                    hideUI()
                    connectionStatusTextView.visibility = View.VISIBLE
                    connectionStatusTextView.text = "Connected"
                    startCallButton.visibility = View.VISIBLE
                    waitingForIncomingCallTextView.visibility = View.VISIBLE
                }
            }
        }
    }

    @SuppressLint("MissingPermission")
    fun startCall() {
        client.serverCall(mapOf("callee" to otherUser)) {
                err, outboundCall ->
            when {
                err != null -> {
                    connectionStatusTextView.text = err.localizedMessage
                }
                else -> {
                    onGoingCall = outboundCall
                    hideUI()
                    endCallButton.visibility = View.VISIBLE
                }
            }
        }
    }


    @SuppressLint("MissingPermission")
    private fun answerCall() {
        callInvite?.answer {
            err, incomingCall ->
            when {
                err != null -> {
                    connectionStatusTextView.text = err.localizedMessage
                }
                else -> {
                    onGoingCall = incomingCall
                    hideUI()
                    endCallButton.visibility = View.VISIBLE
                }
            }
        }
    }

    private fun rejectCall() {
        callInvite?.reject {
                err ->
            when {
                err != null -> {
                    connectionStatusTextView.text = err.localizedMessage
                }
                else -> {
                    hideUI()
                    startCallButton.visibility = View.VISIBLE
                    waitingForIncomingCallTextView.visibility = View.VISIBLE
                }
            }
        }
        onGoingCall = null
    }

    private fun endCall() {
        onGoingCall?.hangup {
                err ->
            when {
                err != null -> {
                    connectionStatusTextView.text = err.localizedMessage
                }
                else -> {
                    hideUI()
                    startCallButton.visibility = View.VISIBLE
                    waitingForIncomingCallTextView.visibility = View.VISIBLE
                }
            }
        }
        onGoingCall = null
    }
}
