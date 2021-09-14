package com.vonage.tutorial.voice.apptophone

import android.Manifest
import android.annotation.SuppressLint
import android.os.Bundle
import android.view.View
import android.widget.Button
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import androidx.core.app.ActivityCompat
import com.nexmo.client.NexmoCall
import com.nexmo.client.NexmoCallEventListener
import com.nexmo.client.NexmoCallHandler
import com.nexmo.client.NexmoMember
import com.nexmo.client.NexmoCallMemberStatus
import com.nexmo.client.NexmoClient
import com.nexmo.client.NexmoMediaActionState
import com.nexmo.client.request_listener.NexmoApiError
import com.nexmo.client.request_listener.NexmoConnectionListener.ConnectionStatus
import com.nexmo.client.request_listener.NexmoRequestListener
import com.vonage.tutorial.voice.apptophone.R

class MainActivity : AppCompatActivity() {

    private lateinit var client: NexmoClient
    var onGoingCall: NexmoCall? = null

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

        // init client
        client = NexmoClient.Builder().build(this)

        client.setConnectionListener { connectionStatus, _ ->
            runOnUiThread { connectionStatusTextView.text = connectionStatus.toString() }

            if (connectionStatus == ConnectionStatus.CONNECTED) {
                runOnUiThread { startCallButton.visibility = View.VISIBLE }

                return@setConnectionListener
            }
        }

        client.login("ALICE_JWT")
    }

    @SuppressLint("MissingPermission")
    fun startCall() {
        client.serverCall("PHONE_NUMBER", null, object : NexmoRequestListener<NexmoCall> {
            override fun onSuccess(call: NexmoCall?) {
                runOnUiThread {
                    endCallButton.visibility = View.VISIBLE
                    startCallButton.visibility = View.INVISIBLE
                }

                onGoingCall = call
                onGoingCall?.addCallEventListener(object : NexmoCallEventListener {
                    override fun onMemberStatusUpdated(callStatus: NexmoCallMemberStatus, callMember: NexmoMember) {
                        if (callStatus == NexmoCallMemberStatus.COMPLETED || callStatus == NexmoCallMemberStatus.CANCELLED) {
                            onGoingCall = null

                            runOnUiThread {
                                endCallButton.visibility = View.INVISIBLE
                                startCallButton.visibility = View.VISIBLE
                            }
                        }
                    }

                    override fun onMuteChanged(nexmoMediaActionState: NexmoMediaActionState, callMember: NexmoMember) {}

                    override fun onEarmuffChanged(nexmoMediaActionState: NexmoMediaActionState, callMember: NexmoMember) {}

                    override fun onDTMF(dtmf: String, callMember: NexmoMember) {}
                })
            }

            override fun onError(apiError: NexmoApiError) {
            }
        })
    }

    private fun hangup() {
        onGoingCall?.hangup(object : NexmoRequestListener<NexmoCall> {
            override fun onSuccess(call: NexmoCall?) {
                onGoingCall = null
            }

            override fun onError(apiError: NexmoApiError) {
            }
        })
    }
}