package com.vonage.tutorial.phonetoapp

import android.Manifest
import android.annotation.SuppressLint
import android.content.pm.PackageManager
import android.os.Bundle
import android.view.View
import android.widget.Button
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.vonage.voice.api.*

class MainActivity : AppCompatActivity() {

    private val aliceJWT = ""
    private var onGoingCall: VoiceCall? = null
    private var callInvite: VoiceInvite? = null
    private lateinit var client: VoiceClient

    private lateinit var connectionStatusTextView: TextView
    private lateinit var answerCallButton: Button
    private lateinit var rejectCallButton: Button
    private lateinit var endCallButton: Button

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        // request permission
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO) != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.RECORD_AUDIO), 123);
        }

        // init views
        connectionStatusTextView = findViewById(R.id.connectionStatusTextView)
        answerCallButton = findViewById(R.id.answerCallButton)
        rejectCallButton = findViewById(R.id.rejectCallButton)
        endCallButton = findViewById(R.id.endCallButton)

        answerCallButton.setOnClickListener { answerCall() }
        rejectCallButton.setOnClickListener { rejectCall() }
        endCallButton.setOnClickListener { endCall() }

        client = VoiceClient(this.application.applicationContext)
        client.setConfig(ClientConfig(ConfigRegion.US))


        client.setCallInviteListener { invite ->
            callInvite = invite
            runOnUiThread {
                answerCallButton.visibility = View.VISIBLE
                rejectCallButton.visibility = View.VISIBLE
                endCallButton.visibility = View.GONE
            }
        }

        client.createSession(aliceJWT, null) {
                err, sessionId ->
            when {
                err != null -> {
                    connectionStatusTextView.text = err.localizedMessage
                }
                else -> {
                    connectionStatusTextView.text = "Connected"
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
                    answerCallButton.visibility = View.GONE
                    rejectCallButton.visibility = View.GONE
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
                    answerCallButton.visibility = View.GONE
                    rejectCallButton.visibility = View.GONE
                    endCallButton.visibility = View.GONE
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
                    answerCallButton.visibility = View.GONE
                    rejectCallButton.visibility = View.GONE
                    endCallButton.visibility = View.GONE
                }
            }
        }
        onGoingCall = null
    }
}