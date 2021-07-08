package com.vonage.tutorial.messaging

import android.os.Handler
import android.os.Looper
import androidx.navigation.NavController
import androidx.navigation.NavDirections

object NavManager {
    private lateinit var navController: NavController

    fun init(navController: NavController) {
        NavManager.navController = navController
    }

    fun navigate(navDirections: NavDirections) {
        Handler(Looper.getMainLooper()).post(Runnable {
            navController.navigate(navDirections)
        })
    }
}
