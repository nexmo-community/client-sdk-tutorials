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
import com.nexmo.client.NexmoCall
import com.nexmo.client.NexmoClient
import com.nexmo.client.request_listener.NexmoApiError
import com.nexmo.client.request_listener.NexmoRequestListener

@SuppressLint("MissingPermission")
class MainActivity : AppCompatActivity() {

    private var call: NexmoCall? = null

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

        // init client
        val client: NexmoClient = NexmoClient.Builder().build(this)

        client.setConnectionListener { connectionStatus, _ ->
            runOnUiThread {
                connectionStatusTextView.text = connectionStatus.toString()
            }
        }

        client.addIncomingCallListener { it ->
            call = it

            answerCallButton.visibility = View.VISIBLE
            rejectCallButton.visibility = View.VISIBLE
            endCallButton.visibility = View.GONE
        }

        client.login("ALICE_JWT")
    }

    private fun answerCall() {
        call?.answer(object : NexmoRequestListener<NexmoCall> {
            override fun onError(p0: NexmoApiError) {
            }

            override fun onSuccess(p0: NexmoCall?) {
                answerCallButton.visibility = View.GONE
                rejectCallButton.visibility = View.GONE
                endCallButton.visibility = View.VISIBLE
            }
        })
    }

    private fun rejectCall() {
        call?.hangup(object : NexmoRequestListener<NexmoCall> {
            override fun onError(p0: NexmoApiError) {
            }

            override fun onSuccess(p0: NexmoCall?) {
                answerCallButton.visibility = View.GONE
                rejectCallButton.visibility = View.GONE
                endCallButton.visibility = View.GONE
            }
        })

        call = null
    }

    private fun endCall() {
        call?.hangup(object : NexmoRequestListener<NexmoCall> {
            override fun onError(p0: NexmoApiError) {
            }

            override fun onSuccess(p0: NexmoCall?) {
                answerCallButton.visibility = View.GONE
                rejectCallButton.visibility = View.GONE
                endCallButton.visibility = View.GONE
            }
        })

        call = null
    }
}