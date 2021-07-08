package com.vonage.tutorial.messaging;

import android.os.Bundle;
import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;
import androidx.navigation.NavController;
import androidx.navigation.Navigation;
import com.nexmo.client.NexmoClient;

public class MainActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        new NexmoClient.Builder().build(this);

        setContentView(R.layout.activity_main);

        NavController navController = Navigation.findNavController(this, R.id.navHostFragment);
        NavManager.getInstance().init(navController);
    }

    @Override
    public void onBackPressed() {
        FragmentManager childFragmentManager =
                getSupportFragmentManager().getPrimaryNavigationFragment().getChildFragmentManager();

        Fragment currentNavigationFragment = childFragmentManager.getFragments().get(0);
        BackPressHandler backPressHandler = (BackPressHandler) currentNavigationFragment;

        if (backPressHandler != null) {
            backPressHandler.onBackPressed();
        }

        super.onBackPressed();
    }
}