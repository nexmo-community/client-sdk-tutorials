package com.vonage.tutorial.apptoapp;

import android.view.View;
import android.widget.LinearLayout;
import androidx.appcompat.app.AppCompatActivity;
import android.os.Bundle;

import java.util.ArrayList;
import java.util.List;

public class MainActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
    }

    private void cleanUI() {
        LinearLayout content = findViewById(R.id.content)

        for(int i =0; i< content.getChildCount(); i++){
            View view = content.getChildAt(i);
            view.setVisibility(View.GONE);
        }
    }
}