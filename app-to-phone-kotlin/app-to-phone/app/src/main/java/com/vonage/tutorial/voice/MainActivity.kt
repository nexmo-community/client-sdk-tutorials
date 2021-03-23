package com.vonage.tutorial.voice

import android.Manifest
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import androidx.core.app.ActivityCompat
import androidx.navigation.Navigation
import com.nexmo.client.NexmoClient

class MainActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        val navController = Navigation.findNavController(this, R.id.navHostFragment)
        NavManager.init(navController)

        val callsPermissions = arrayOf(Manifest.permission.RECORD_AUDIO)
        ActivityCompat.requestPermissions(this, callsPermissions, 123)

        NexmoClient.Builder().build(this)
    }

    override fun onBackPressed() {
        val childFragmentManager = supportFragmentManager.primaryNavigationFragment?.childFragmentManager
        val currentNavigationFragment = childFragmentManager?.fragments?.first()

        if(currentNavigationFragment is BackPressHandler) {
            currentNavigationFragment.onBackPressed()
        }

        super.onBackPressed()
    }
}