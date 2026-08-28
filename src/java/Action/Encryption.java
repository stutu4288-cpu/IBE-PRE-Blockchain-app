package Action;

import java.io.InputStream;
import java.io.OutputStream;
import java.security.SecureRandom;
import java.util.Base64;
import javax.crypto.Cipher;
import javax.crypto.CipherInputStream;
import javax.crypto.CipherOutputStream;
import javax.crypto.SecretKey;
import javax.crypto.spec.GCMParameterSpec;
import javax.crypto.spec.IvParameterSpec;

/**
 * Enterprise Binary Stream & File Encryption Engine.
 * Supports Authenticated AES-GCM (12-byte IV + 128-bit tag) and AES-CBC
 * with pure InputStream/OutputStream stream piping and zero String coercion.
 */
public class Encryption {

    private static final int GCM_IV_LENGTH = 12; // 12-byte standard GCM IV
    private static final int GCM_TAG_LENGTH = 128; // 128-bit authentication tag
    private static final SecureRandom SECURE_RANDOM = new SecureRandom();

    /**
     * Encrypts a binary InputStream directly to an OutputStream using AES-GCM.
     * Writes [12-byte IV] followed by the authenticated ciphertext stream.
     */
    public void encryptGCM(InputStream in, OutputStream out, SecretKey secretKey) throws Exception {
        if (in == null || out == null || secretKey == null) return;
        byte[] iv = new byte[GCM_IV_LENGTH];
        SECURE_RANDOM.nextBytes(iv);
        out.write(iv); // Write 12-byte IV header first

        Cipher cipher = Cipher.getInstance("AES/GCM/NoPadding");
        GCMParameterSpec gcmSpec = new GCMParameterSpec(GCM_TAG_LENGTH, iv);
        cipher.init(Cipher.ENCRYPT_MODE, secretKey, gcmSpec);

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
     * Encrypts an arbitrary binary byte array using AES-GCM.
     */
    public byte[] encryptGCM(byte[] plainBytes, SecretKey secretKey) {
        if (plainBytes == null || secretKey == null) return null;
        try {
            byte[] iv = new byte[GCM_IV_LENGTH];
            SECURE_RANDOM.nextBytes(iv);

            Cipher cipher = Cipher.getInstance("AES/GCM/NoPadding");
            GCMParameterSpec gcmSpec = new GCMParameterSpec(GCM_TAG_LENGTH, iv);
            cipher.init(Cipher.ENCRYPT_MODE, secretKey, gcmSpec);

            byte[] cipherBytes = cipher.doFinal(plainBytes);

            byte[] ivAndCipher = new byte[iv.length + cipherBytes.length];
            System.arraycopy(iv, 0, ivAndCipher, 0, iv.length);
            System.arraycopy(cipherBytes, 0, ivAndCipher, iv.length, cipherBytes.length);

            return ivAndCipher;
        } catch (Exception e) {
            return encryptCBC(plainBytes, secretKey);
        }
    }

    /**
     * Fallback AES-CBC encryption for binary byte arrays.
     */
    public byte[] encryptCBC(byte[] plainBytes, SecretKey secretKey) {
        if (plainBytes == null || secretKey == null) return null;
        try {
            byte[] iv = new byte[16];
            SECURE_RANDOM.nextBytes(iv);
            IvParameterSpec ivSpec = new IvParameterSpec(iv);

            Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");
            cipher.init(Cipher.ENCRYPT_MODE, secretKey, ivSpec);

            byte[] cipherBytes = cipher.doFinal(plainBytes);

            byte[] ivAndCipher = new byte[iv.length + cipherBytes.length];
            System.arraycopy(iv, 0, ivAndCipher, 0, iv.length);
            System.arraycopy(cipherBytes, 0, ivAndCipher, iv.length, cipherBytes.length);

            return ivAndCipher;
        } catch (Exception e) {
            return null;
        }
    }

    /**
     * Overload for text/Base64 transport envelope inputs.
     */
    public String encrypt(String text, SecretKey secretKey) {
        if (text == null || secretKey == null) return null;
        try {
            byte[] plainBytes = text.getBytes("UTF-8");
            byte[] encBytes = encryptGCM(plainBytes, secretKey);
            if (encBytes == null) encBytes = encryptCBC(plainBytes, secretKey);
            return encBytes != null ? Base64.getEncoder().encodeToString(encBytes) : null;
        } catch (Exception e) {
            return null;
        }
    }
}
