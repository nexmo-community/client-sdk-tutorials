package com.vonage.tutorial.messaging;

import android.os.Handler;
import android.os.Looper;
import androidx.navigation.NavController;
import androidx.navigation.NavDirections;

public final class NavManager {

    private static NavManager INSTANCE;
    NavController navController;

    public static NavManager getInstance() {
        if (INSTANCE == null) {
            INSTANCE = new NavManager();
        }

        return INSTANCE;
    }

    public void init(NavController navController) {
        this.navController = navController;
    }

    public void navigate(NavDirections navDirections) {
        new Handler(Looper.getMainLooper()).post(new Runnable() {
            @Override
            public void run() {
                navController.navigate(navDirections);
            }
        });
    }
}
