package com.example.bar.qrscanner;

import android.content.ContentResolver;
import android.provider.Settings.Secure;

@SuppressWarnings("all")
public class SecureIdVendor {

    private String secureId = null;

    public SecureIdVendor(ContentResolver contentResolver) {
        find(contentResolver);
    }

    private void find(ContentResolver contentResolver) {
        this.secureId = Secure.getString(contentResolver, Secure.ANDROID_ID);
    }

    public String get() {
        return secureId;
    }
}
