package com.vonage.tutorial.apptoapp

import android.Manifest
import android.annotation.SuppressLint
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView
import androidx.annotation.VisibleForTesting
import androidx.core.app.ActivityCompat
import androidx.core.view.forEach
import com.nexmo.client.NexmoClient
import com.nexmo.client.request_listener.NexmoConnectionListener

class MainActivity : AppCompatActivity() {
    private lateinit var client: NexmoClient
    private var loggedInUser: String = ""

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
        startCallButton.setOnClickListener { startCall() }
        answerCallButton.setOnClickListener { answerCall() }
        rejectCallButton.setOnClickListener { rejectCall() }
        endCallButton.setOnClickListener { endCall() }

        client = NexmoClient.Builder().build(this)

        client.setConnectionListener { connectionStatus, _ ->
            runOnUiThread { connectionStatusTextView.text = connectionStatus.toString() }

            if (connectionStatus == NexmoConnectionListener.ConnectionStatus.CONNECTED) {
                runOnUiThread {
                    cleanUI()
                    connectionStatusTextView.visibility = View.VISIBLE

                    if(loggedInUser == "Alice") {
                        startCallButton.visibility = View.VISIBLE

                    } else if (loggedInUser == "Bob"){
                        waitingForIncomingCallTextView.visibility = View.VISIBLE
                    }
                }

                return@setConnectionListener
            }
        }
    }

    private fun cleanUI() {
        val content = findViewById<LinearLayout>(R.id.content)
        content.forEach { it.visibility = View.GONE }
    }

    private fun loginAsAlice() {
        loggedInUser = "Alice"
        client.login("eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpYXQiOjE2MTY3NzAwMzksImp0aSI6IjJhNjM3OTQwLThlNDItMTFlYi1hZjQxLTc1M2I2MjAxYjQ2OSIsImV4cCI6MTYxNjg1NjQzOCwiYWNsIjp7InBhdGhzIjp7Ii8qL3VzZXJzLyoqIjp7fSwiLyovY29udmVyc2F0aW9ucy8qKiI6e30sIi8qL3Nlc3Npb25zLyoqIjp7fSwiLyovZGV2aWNlcy8qKiI6e30sIi8qL2ltYWdlLyoqIjp7fSwiLyovbWVkaWEvKioiOnt9LCIvKi9hcHBsaWNhdGlvbnMvKioiOnt9LCIvKi9wdXNoLyoqIjp7fSwiLyova25vY2tpbmcvKioiOnt9LCIvKi9sZWdzLyoqIjp7fX19LCJzdWIiOiJBbGljZSIsImFwcGxpY2F0aW9uX2lkIjoiZmU1YmJlNTctOTc1Yy00OWZkLTljMDUtNjUwOWM5MjIyN2I0In0.CLGHqZzvzW98C6VOK8XjV2ye32CZ9X4ZQY_rYwX9liCUpqnLwST5Z_mXyrLnGgceZG3gGf684f-IiqAN4nqbQqOKxwJOo28q4jNZwg0KdIlyduLaAb1pkNMn5eUG85ZUxmojPfbUBQfmtBaX5j-Ve0yJ3wCaIU8APekMqf3IZIOGTZMqN7hp0DGBnyz_nLcIqeLvnvt5mV5tpwycxHujYCRoOWqpiXAUj7pp0EdFJmtOqQY77AQ5-NgI_NVltL2AMERnA8U9721nMjVIuBM0BEPiltp0Is9ZZ2FoX_hjPMYy6th6u7TzOsdaNT1dcUDdTdHfG-yhcEvvvr-UMpnGtQ")
    }

    private fun loginAsBob() {
        loggedInUser = "Bob"
        client.login("eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpYXQiOjE2MTY3NzAwNTUsImp0aSI6IjMzYjM4MWMwLThlNDItMTFlYi04YzJhLTkzMGFmMjE5YmEwNiIsImV4cCI6MTYxNjg1NjQ1NCwiYWNsIjp7InBhdGhzIjp7Ii8qL3VzZXJzLyoqIjp7fSwiLyovY29udmVyc2F0aW9ucy8qKiI6e30sIi8qL3Nlc3Npb25zLyoqIjp7fSwiLyovZGV2aWNlcy8qKiI6e30sIi8qL2ltYWdlLyoqIjp7fSwiLyovbWVkaWEvKioiOnt9LCIvKi9hcHBsaWNhdGlvbnMvKioiOnt9LCIvKi9wdXNoLyoqIjp7fSwiLyova25vY2tpbmcvKioiOnt9LCIvKi9sZWdzLyoqIjp7fX19LCJzdWIiOiJCb2IiLCJhcHBsaWNhdGlvbl9pZCI6ImZlNWJiZTU3LTk3NWMtNDlmZC05YzA1LTY1MDljOTIyMjdiNCJ9.MX3hFQdNQYF4E9vRny8KSj5aYhvSBd1YlVdveACeboDXo0VCj8d5_Vnw7WibQ0QXG-D_2do83lwGBtR-awwscEQp8PnJz7O1MnlZKHc9XXqyV3x30tjxUkAm2TmadGAn1INl6rTNkcrVEeFA8Fw8VyflfF63OyZSipVHM8c_X3SkGmVIEB7NCjeZlyHCZexrNvtXiqMSjuj9jW1yRmWKRU-ZJA_-CRaMZIqy8ZSsO-kR0XFrgMoK4ddMRWza0gauMzA74mdaPxdjep1Dq7hfN7BewC_HVFbINP-uqc0ZyyKh2hQQyFKFidOD6pZGtK9EKiLIfSIeSooMZx1tr3YRUQ")
    }

    @SuppressLint("MissingPermission")
    private fun startCall() {
        // TODO: update body
    }

    private fun answerCall() {
        // TODO: update body
    }

    private fun rejectCall() {
        // TODO: update body
    }

    private fun endCall() {
        // TODO: update body
    }
}
