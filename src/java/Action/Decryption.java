package Action;

import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.Base64;
import javax.crypto.Cipher;
import javax.crypto.SecretKey;
import javax.crypto.spec.GCMParameterSpec;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;

/**
 * Enterprise Binary Stream & File Decryption Engine.
 * Supports Authenticated AES-GCM (12-byte IV + 128-bit tag), AES-CBC (16-byte IV),
 * and streaming decryption directly to OutputStream with zero String coercion.
 */
public class Decryption {

    private static final int GCM_IV_LENGTH = 12; // 12-byte standard GCM IV
    private static final int GCM_TAG_LENGTH = 128; // 128-bit authentication tag

    /**
     * Decrypts an InputStream containing [12-byte IV] + [AES-GCM Ciphertext] directly to an OutputStream.
     */
    public void decryptGCM(InputStream in, OutputStream out, SecretKey secretKey) throws Exception {
        if (in == null || out == null || secretKey == null) return;
        byte[] iv = new byte[GCM_IV_LENGTH];
        int ivRead = in.readNBytes(iv, 0, GCM_IV_LENGTH);
        if (ivRead < GCM_IV_LENGTH) {
            throw new IllegalArgumentException("Stream truncated: missing 12-byte GCM IV header.");
        }

        Cipher cipher = Cipher.getInstance("AES/GCM/NoPadding");
        GCMParameterSpec gcmSpec = new GCMParameterSpec(GCM_TAG_LENGTH, iv);
        cipher.init(Cipher.DECRYPT_MODE, secretKey, gcmSpec);

        byte[] inBuffer = new byte[8192];
        int read;
        while ((read = in.read(inBuffer)) != -1) {
            byte[] output = cipher.update(inBuffer, 0, read);
            if (output != null) out.write(output);
        }
        byte[] finalOutput = cipher.doFinal();
        if (finalOutput != null) out.write(finalOutput);
        out.flush();
    }

    /**
     * Decrypts an arbitrary binary byte array using AES-GCM.
     */
    public byte[] decryptGCM(byte[] ivAndCipher, SecretKey secretKey) {
        if (ivAndCipher == null || secretKey == null || ivAndCipher.length <= GCM_IV_LENGTH) {
            return null;
        }
        try {
            byte[] iv = new byte[GCM_IV_LENGTH];
            byte[] cipherBytes = new byte[ivAndCipher.length - GCM_IV_LENGTH];
            System.arraycopy(ivAndCipher, 0, iv, 0, GCM_IV_LENGTH);
            System.arraycopy(ivAndCipher, GCM_IV_LENGTH, cipherBytes, 0, cipherBytes.length);

            Cipher cipher = Cipher.getInstance("AES/GCM/NoPadding");
            GCMParameterSpec gcmSpec = new GCMParameterSpec(GCM_TAG_LENGTH, iv);
            cipher.init(Cipher.DECRYPT_MODE, secretKey, gcmSpec);

            return cipher.doFinal(cipherBytes);
        } catch (Exception e) {
            return null;
        }
    }

    /**
     * Decrypts an arbitrary binary byte array using AES-CBC (16-byte IV prefix).
     */
    public byte[] decryptCBC(byte[] ivAndCipher, SecretKey secretKey) {
        if (ivAndCipher == null || secretKey == null || ivAndCipher.length <= 16) {
            return null;
        }
        try {
            byte[] iv = new byte[16];
            byte[] cipherBytes = new byte[ivAndCipher.length - 16];
            System.arraycopy(ivAndCipher, 0, iv, 0, 16);
            System.arraycopy(ivAndCipher, 16, cipherBytes, 0, cipherBytes.length);

            IvParameterSpec ivSpec = new IvParameterSpec(iv);
            Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");
            cipher.init(Cipher.DECRYPT_MODE, secretKey, ivSpec);

            return cipher.doFinal(cipherBytes);
        } catch (Exception e) {
            return null;
        }
    }

    /**
     * Lossless binary decryption trying GCM -> CBC -> ECB in sequence.
     */
    public byte[] decryptBytes(byte[] cipherBytes, SecretKey secretKey) {
        if (cipherBytes == null || secretKey == null || cipherBytes.length == 0) {
            return null;
        }

        // 1. Try Authenticated AES-GCM mode
        byte[] result = decryptGCM(cipherBytes, secretKey);
        if (result != null && result.length > 0) {
            return result;
        }

        // 2. Try AES-CBC with 16-byte IV
        result = decryptCBC(cipherBytes, secretKey);
        if (result != null && result.length > 0) {
            return result;
        }

        // 3. Fallback for legacy AES-ECB
        try {
            Cipher cipher = Cipher.getInstance("AES");
            cipher.init(Cipher.DECRYPT_MODE, secretKey);
            result = cipher.doFinal(cipherBytes);
            if (result != null && result.length > 0) {
                return result;
            }
        } catch (Exception exEcb) {
            // Null on error
        }

        return null;
    }

    /**
     * Decrypts InputStream stream directly to byte[] with multi-mode fallbacks.
     */
    public byte[] decryptStream(InputStream in, SecretKey secretKey) {
        if (in == null || secretKey == null) return null;
        try {
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            CryptoUtils.transfer(in, baos);
            return decryptBytes(baos.toByteArray(), secretKey);
        } catch (Exception e) {
            return null;
        }
    }

    /**
     * Overloaded decryptBytes taking Base64 or raw string inputs.
     */
    public byte[] decryptBytes(String cipherStr, String keyStr) {
        if (cipherStr == null || keyStr == null || cipherStr.trim().isEmpty() || keyStr.trim().isEmpty()) {
            return null;
        }
        try {
            byte[] keyBytes = Base64.getDecoder().decode(keyStr.trim().replaceAll("\\s+", ""));
            SecretKey secretKey = new SecretKeySpec(keyBytes, "AES");

            byte[] cipherBytes;
            String cleanCipher = cipherStr.trim().replaceAll("\\s+", "");
            try {
                cipherBytes = Base64.getDecoder().decode(cleanCipher);
            } catch (Exception exB64) {
                cipherBytes = cipherStr.getBytes("UTF-8");
            }

            return decryptBytes(cipherBytes, secretKey);
        } catch (Exception e) {
            return null;
        }
    }

    /**
     * String wrapper for backwards compatibility.
     */
    public String decrypt(String txt, String skey) {
        byte[] b = decryptBytes(txt, skey);
        if (b == null) return null;
        try {
            return new String(b, "UTF-8");
        } catch (Exception e) {
            return Base64.getEncoder().encodeToString(b);
        }
    }
}
