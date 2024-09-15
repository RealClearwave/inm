package com.clearwave.inm;

import android.os.Bundle;
import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.plugin.common.MethodChannel;

import com.atilika.kuromoji.ipadic.Token;
import com.atilika.kuromoji.ipadic.Tokenizer;

import java.util.List;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.clearwave.inm/tokenize";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler((call, result) -> {
                    if (call.method.equals("tokenize")) {
                        String text = call.argument("text");
                        String tokens = tokenizeText(text);
                        result.success(tokens);
                    } else {
                        result.notImplemented();
                    }
                });
    }

    private String tokenizeText(String text) {
        Tokenizer tokenizer = new Tokenizer();
        List<Token> tokens = tokenizer.tokenize(text);

        StringBuilder tokenResult = new StringBuilder();
        for (Token token : tokens) {
            tokenResult.append(token.getSurface()).append("\t").append(token.getAllFeatures()).append("\n");
        }
        return tokenResult.toString();
    }
}
