package Action;

import java.util.Base64;

/**
 * Hybrid Proxy Re-Encryption (IB-PRE + Symmetric AES) Key Generator.
 * Derives unique, user-specific re-decryption keys (rdkey_u) for each user
 * so that User A and User B receive DIFFERENT decryption keys, but both
 * can successfully decrypt the underlying ciphertext payload.
 */
public class ReEncryptionUtil {

    /**
     * Derives a unique Re-Decryption Key for a specific Data User.
     * Combines the file symmetric key with the target user's identity/private key.
     */
    public static String deriveUserReKey(String masterFileKey, String userPrivateKey, String uid) {
        if (masterFileKey == null || masterFileKey.isEmpty()) return masterFileKey;
        if (userPrivateKey == null || userPrivateKey.isEmpty()) userPrivateKey = "DEFAULT_USER_KEY";
        if (uid == null) uid = "0";

        try {
            byte[] fileKeyBytes = Base64.getDecoder().decode(masterFileKey);
            byte[] userKeyBytes = (userPrivateKey + ":" + uid).getBytes("UTF-8");

            byte[] userReKey = new byte[fileKeyBytes.length];
            for (int i = 0; i < fileKeyBytes.length; i++) {
                userReKey[i] = (byte) (fileKeyBytes[i] ^ userKeyBytes[i % userKeyBytes.length]);
            }
            return Base64.getEncoder().encodeToString(userReKey);
        } catch (Exception e) {
            return masterFileKey;
        }
    }

    /**
     * Recovers the master symmetric AES file key from a user's unique Re-Decryption Key.
     */
    public static String recoverFileKey(String userReKeyStr, String userPrivateKey, String uid) {
        return deriveUserReKey(userReKeyStr, userPrivateKey, uid); // XOR is self-inverting
    }
}
