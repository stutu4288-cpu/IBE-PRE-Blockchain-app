package Action;

import java.io.InputStream;
import java.io.OutputStream;
import java.security.MessageDigest;
import java.util.Arrays;

/**
 * Enterprise Binary Stream & Cryptography Utilities.
 * Enforces pure InputStream/OutputStream chunked streaming, SHA-256 stream hashing,
 * and comprehensive MIME resolution with zero String coercion.
 */
public class CryptoUtils {

    private static final int BUFFER_SIZE = 8192; // 8KB chunk buffer

    /**
     * Streams data directly from InputStream to OutputStream chunk-by-chunk without full buffering.
     * Uses Java 9+ InputStream.transferTo when available, with chunked buffer fallback.
     */
    public static long transfer(InputStream in, OutputStream out) throws java.io.IOException {
        if (in == null || out == null) return 0;
        try {
            return in.transferTo(out);
        } catch (NoSuchMethodError e) {
            byte[] buffer = new byte[BUFFER_SIZE];
            long total = 0;
            int read;
            while ((read = in.read(buffer)) != -1) {
                out.write(buffer, 0, read);
                total += read;
            }
            out.flush();
            return total;
        }
    }

    /**
     * Computes the SHA-256 checksum of an InputStream stream chunk-by-chunk.
     * Returns a 64-character lowercase hex string.
     */
    public static String sha256(InputStream is) {
        if (is == null) return "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855";
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] buffer = new byte[BUFFER_SIZE];
            int read;
            while ((read = is.read(buffer)) != -1) {
                md.update(buffer, 0, read);
            }
            byte[] hashBytes = md.digest();
            StringBuilder sb = new StringBuilder(hashBytes.length * 2);
            for (byte b : hashBytes) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (Exception e) {
            return "hash-error";
        }
    }

    /**
     * Computes the SHA-256 checksum of a binary byte array.
     */
    public static String sha256(byte[] data) {
        if (data == null || data.length == 0) {
            return "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855";
        }
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hashBytes = md.digest(data);
            StringBuilder sb = new StringBuilder(hashBytes.length * 2);
            for (byte b : hashBytes) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (Exception e) {
            return "hash-error";
        }
    }

    /**
     * Verifies whether two byte arrays are strictly identical.
     */
    public static boolean verifyIntegrity(byte[] original, byte[] restored) {
        if (original == null || restored == null) {
            return false;
        }
        return Arrays.equals(original, restored);
    }

    /**
     * Resolves the standard MIME content type for any document, media, or archive file.
     */
    public static String resolveMimeType(String filename) {
        if (filename == null) return "application/octet-stream";
        String lower = filename.toLowerCase().trim();

        if (lower.endsWith(".pdf")) return "application/pdf";
        if (lower.endsWith(".docx")) return "application/vnd.openxmlformats-officedocument.wordprocessingml.document";
        if (lower.endsWith(".doc")) return "application/msword";
        if (lower.endsWith(".xlsx")) return "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
        if (lower.endsWith(".xls")) return "application/vnd.ms-excel";
        if (lower.endsWith(".pptx")) return "application/vnd.openxmlformats-officedocument.presentationml.presentation";
        if (lower.endsWith(".ppt")) return "application/vnd.ms-powerpoint";
        if (lower.endsWith(".png")) return "image/png";
        if (lower.endsWith(".jpg") || lower.endsWith(".jpeg")) return "image/jpeg";
        if (lower.endsWith(".gif")) return "image/gif";
        if (lower.endsWith(".webp")) return "image/webp";
        if (lower.endsWith(".svg")) return "image/svg+xml";
        if (lower.endsWith(".mp4")) return "video/mp4";
        if (lower.endsWith(".avi")) return "video/x-msvideo";
        if (lower.endsWith(".mkv")) return "video/x-matroska";
        if (lower.endsWith(".mp3")) return "audio/mpeg";
        if (lower.endsWith(".wav")) return "audio/wav";
        if (lower.endsWith(".zip")) return "application/zip";
        if (lower.endsWith(".rar")) return "application/x-rar-compressed";
        if (lower.endsWith(".7z")) return "application/x-7z-compressed";
        if (lower.endsWith(".txt")) return "text/plain";
        if (lower.endsWith(".json")) return "application/json";
        if (lower.endsWith(".xml")) return "application/xml";
        if (lower.endsWith(".csv")) return "text/csv";

        return "application/octet-stream";
    }
}
