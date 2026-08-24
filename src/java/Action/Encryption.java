package Action;

import java.security.SecureRandom;
import java.util.Base64;
import javax.crypto.Cipher;
import javax.crypto.SecretKey;
import javax.crypto.spec.IvParameterSpec;

public class Encryption {

    public String encrypt(String text, SecretKey secretkey) {
        try {
            // Generate a random 16-byte IV for CBC mode
            byte[] iv = new byte[16];
            new SecureRandom().nextBytes(iv);
            IvParameterSpec ivSpec = new IvParameterSpec(iv);

            Cipher aesCipher = Cipher.getInstance("AES/CBC/PKCS5Padding");
            aesCipher.init(Cipher.ENCRYPT_MODE, secretkey, ivSpec);

            byte[] cipherBytes = aesCipher.doFinal(text.getBytes("UTF-8"));

            // Prepend IV to ciphertext and encode together as Base64
            byte[] ivAndCipher = new byte[iv.length + cipherBytes.length];
            System.arraycopy(iv, 0, ivAndCipher, 0, iv.length);
            System.arraycopy(cipherBytes, 0, ivAndCipher, iv.length, cipherBytes.length);

            String cipherText = Base64.getEncoder().encodeToString(ivAndCipher);
            System.out.println("\n Given text : " + text + " \n Cipher Data : " + cipherText);
            return cipherText;

        } catch (Exception e) {
            System.out.println("Encryption error: " + e);
            return null;
        }
    }
}

