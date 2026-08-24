package Action;

import javax.crypto.Cipher;
import javax.crypto.SecretKey;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import java.util.Base64;

public class Decryption {

    public String decrypt(String txt, String skey) {
        try {
            // Rebuild the SecretKey from Base64 string
            byte[] keyBytes = Base64.getDecoder().decode(skey);
            SecretKey sec = new SecretKeySpec(keyBytes, "AES");

            // Decode the stored value (IV + CipherText)
            byte[] ivAndCipher = Base64.getDecoder().decode(txt);

            // Extract the 16-byte IV prefix
            byte[] iv = new byte[16];
            byte[] cipherBytes = new byte[ivAndCipher.length - 16];
            System.arraycopy(ivAndCipher, 0, iv, 0, 16);
            System.arraycopy(ivAndCipher, 16, cipherBytes, 0, cipherBytes.length);

            IvParameterSpec ivSpec = new IvParameterSpec(iv);
            Cipher aesCipher = Cipher.getInstance("AES/CBC/PKCS5Padding");
            aesCipher.init(Cipher.DECRYPT_MODE, sec, ivSpec);

            byte[] decryptedBytes = aesCipher.doFinal(cipherBytes);
            String decryptedText = new String(decryptedBytes, "UTF-8");
            System.out.println("Decrypted Text: " + decryptedText);
            return decryptedText;

        } catch (Exception e) {
            System.out.println("Decryption error: " + e);
            return null;
        }
    }
}

