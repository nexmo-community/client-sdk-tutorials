package com.vonage.tutorial.voice.apptophone

import android.Manifest
import android.annotation.SuppressLint
import android.os.Bundle
import android.view.View
import android.widget.Button
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import androidx.core.app.ActivityCompat
import com.vonage.voice.api.ClientConfig
import com.vonage.voice.api.ConfigRegion
import com.vonage.voice.api.VoiceCall
import com.vonage.voice.api.VoiceClient

class MainActivity : AppCompatActivity() {

    //Replace this with your generated JWT
    private val aliceJWT = ""
    private lateinit var client: VoiceClient
    var onGoingCall: VoiceCall? = null

    private lateinit var startCallButton: Button
    private lateinit var endCallButton: Button
    private lateinit var connectionStatusTextView: TextView

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        // request permissions
        val callsPermissions = arrayOf(Manifest.permission.RECORD_AUDIO)
        ActivityCompat.requestPermissions(this, callsPermissions, 123)

        // init views
        startCallButton = findViewById(R.id.makeCallButton)
        endCallButton = findViewById(R.id.endCallButton)
        connectionStatusTextView = findViewById(R.id.connectionStatusTextView)

        startCallButton.setOnClickListener {
            startCall()
        }

        endCallButton.setOnClickListener {
            hangup()
        }

        client = VoiceClient(this.application.applicationContext)
        client.setConfig(ClientConfig(ConfigRegion.US))

        client.createSession(aliceJWT, null) {
            err, sessionId ->
            when {
                err != null -> {
                    connectionStatusTextView.text = err.localizedMessage
                    startCallButton.visibility = View.INVISIBLE
                    endCallButton.visibility = View.INVISIBLE
                }
                else -> {
                    connectionStatusTextView.text = "Connected"
                    startCallButton.visibility = View.VISIBLE
                    endCallButton.visibility = View.INVISIBLE
                }
            }
        }
    }

    @SuppressLint("MissingPermission")
    fun startCall() {
        client.serverCall(mapOf("to" to "+447528640068")) {
            err, outboundCall ->
            when {
                err != null -> {
                    connectionStatusTextView.text = err.localizedMessage
                }
                else -> {
                    onGoingCall = outboundCall
                    startCallButton.visibility = View.INVISIBLE
                    endCallButton.visibility = View.VISIBLE
                }
            }
        }

    }

    private fun hangup() {
        onGoingCall?.hangup() {
            err ->
            when {
                err != null -> {
                    connectionStatusTextView.text = err.localizedMessage
                }
                else -> {
                    onGoingCall = null
                }
            }
        }
    }
}