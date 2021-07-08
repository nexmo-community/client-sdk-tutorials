package com.vonage.tutorial.messaging

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import androidx.navigation.Navigation.findNavController
import com.nexmo.client.NexmoClient

class MainActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        NexmoClient.Builder().build(this)

        setContentView(R.layout.activity_main)

        val navController = findNavController(this, R.id.navHostFragment)
        NavManager.init(navController)


    }

    override fun onBackPressed() {
        val childFragmentManager = supportFragmentManager.primaryNavigationFragment?.childFragmentManager
        val currentNavigationFragment = childFragmentManager?.fragments?.first()

        if (currentNavigationFragment is BackPressHandler) {
            currentNavigationFragment.onBackPressed()
        }

        super.onBackPressed()
    }
}