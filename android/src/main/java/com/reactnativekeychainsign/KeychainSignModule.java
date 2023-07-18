package com.reactnativekeychainsign;

import androidx.annotation.NonNull;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.module.annotations.ReactModule;

import android.security.keystore.KeyGenParameterSpec;
import android.security.keystore.KeyProperties;
import java.security.KeyStore;
import java.security.KeyPairGenerator;
import java.security.KeyPair;
import java.security.PrivateKey;
import java.security.PublicKey;
import java.security.Signature;
import java.util.Base64;

@ReactModule(name = KeychainSignModule.NAME)
public class KeychainSignModule extends ReactContextBaseJavaModule {

    public static final String NAME = "KeychainSign";
    private static final String KEYSTORE_PROVIDER = "AndroidKeyStore";

    public KeychainSignModule(ReactApplicationContext context) {
        super(context);
    }

    @Override
    public String getName() {
        return NAME;
    }

    @ReactMethod
    public void generateKeys(String alias, boolean requiresUserAuthentication, Promise promise) {
        String algorithm = "ES256";
        try {
            KeyPairGenerator keyPairGenerator = KeyPairGenerator.getInstance(
                    getAlgorithmForKeyPairGenerator(algorithm), KEYSTORE_PROVIDER
            );
            keyPairGenerator.initialize(
                    new KeyGenParameterSpec.Builder(
                            alias,
                            KeyProperties.PURPOSE_SIGN | KeyProperties.PURPOSE_VERIFY
                    )
                            .setDigests(getDigest(algorithm))
                            .setUserAuthenticationRequired(false)
                            .build()
            );
            keyPairGenerator.generateKeyPair();
            promise.resolve(null);
        } catch (Exception e) {
            promise.reject(e);
        }
    }

    @ReactMethod
    public void getPublicKeyByTag(String alias, Promise promise) {
        try {
            KeyStore keyStore = KeyStore.getInstance(KEYSTORE_PROVIDER);
            keyStore.load(null);
            PublicKey publicKey = keyStore.getCertificate(alias).getPublicKey();
            byte[] publicKeyBytes = publicKey.getEncoded();
            promise.resolve(Base64.getEncoder().encodeToString(publicKeyBytes));
        } catch (Exception e) {
            promise.reject(e);
        }
    }

    @ReactMethod
    public void signData(String data, String alias, String algorithm, Promise promise) {
        try {
            KeyStore keyStore = KeyStore.getInstance(KEYSTORE_PROVIDER);
            keyStore.load(null);
            PrivateKey privateKey = (PrivateKey) keyStore.getKey(alias, null);
            Signature signature = Signature.getInstance(getAlgorithmForSignature(algorithm));
            signature.initSign(privateKey);
            signature.update(data.getBytes("UTF-8"));
            byte[] signatureBytes = signature.sign();
            promise.resolve(Base64.getEncoder().encodeToString(signatureBytes));
        } catch (Exception e) {
            promise.reject(e);
        }
    }

    private String getAlgorithmForKeyPairGenerator(String name) {
        switch (name) {
            case "ES256":
            case "ES384":
            case "ES512":
                return "EC";
            default:
                return "RSA";
        }
    }

    private String getDigest(String name) {
        switch (name) {
            case "ES256":
                return KeyProperties.DIGEST_SHA256;
            case "ES384":
                return KeyProperties.DIGEST_SHA384;
            case "ES512":
                return KeyProperties.DIGEST_SHA512;
            default:
                return KeyProperties.DIGEST_SHA256;
        }
    }

    private String getAlgorithmForSignature(String name) {
        switch (name) {
            case "ES256":
                return "SHA256withECDSA";
            case "ES384":
                return "SHA384withECDSA";
            case "ES512":
                return "SHA512withECDSA";
            default:
                return "SHA256withRSA";
        }
    }
}

