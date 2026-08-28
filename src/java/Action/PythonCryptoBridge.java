package Action;

import java.io.BufferedReader;
import java.io.File;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.nio.charset.StandardCharsets;
import java.util.Base64;

/**
 * Enterprise Python Cryptographic & File Processing Bridge.
 * Connects Java to:
 * 1. Python PRE Engine (Proxy Re-Encryption Key Transformation)
 * 2. Python File Processor (pypdf, python-docx, Pillow) for deep structure verification and conversion
 */
public class PythonCryptoBridge {

    private static Boolean pythonAvailable = null;
    private static String preScriptPath = null;
    private static String converterScriptPath = null;

    /**
     * Checks if Python runtime and the scripts are accessible.
     */
    public static synchronized boolean isPythonAvailable() {
        if (pythonAvailable != null) {
            return pythonAvailable;
        }
        try {
            File script = new File("python_service/pre_service.py");
            if (!script.exists()) script = new File("../python_service/pre_service.py");

            File convScript = new File("python_service/file_converter.py");
            if (!convScript.exists()) convScript = new File("../python_service/file_converter.py");

            if (script.exists()) {
                preScriptPath = script.getAbsolutePath();
                if (convScript.exists()) converterScriptPath = convScript.getAbsolutePath();
                
                ProcessBuilder pb = new ProcessBuilder("python", "--version");
                Process p = pb.start();
                int exitCode = p.waitFor();
                pythonAvailable = (exitCode == 0);
            } else {
                pythonAvailable = false;
            }
        } catch (Exception e) {
            pythonAvailable = false;
        }
        return pythonAvailable;
    }

    /**
     * Derives a user re-encryption key using the Python PRE engine.
     */
    public static String deriveUserReKey(String masterKeyBase64, String userPrivateKey, String uid) {
        if (isPythonAvailable() && preScriptPath != null) {
            try {
                ProcessBuilder pb = new ProcessBuilder(
                    "python", preScriptPath, "derive", masterKeyBase64, userPrivateKey, uid
                );
                pb.redirectErrorStream(true);
                Process process = pb.start();

                try (BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream(), StandardCharsets.UTF_8))) {
                    String line = reader.readLine();
                    int exitCode = process.waitFor();
                    if (exitCode == 0 && line != null && !line.trim().isEmpty()) {
                        return line.trim();
                    }
                }
            } catch (Exception e) {
                System.err.println("Python PRE derive fallback: " + e.getMessage());
            }
        }
        return ReEncryptionUtil.deriveUserReKey(masterKeyBase64, userPrivateKey, uid);
    }

    /**
     * Recovers the original master AES file key from user re-key using the Python PRE engine.
     */
    public static String recoverFileKey(String userReKey, String userPrivateKey, String uid) {
        if (isPythonAvailable() && preScriptPath != null) {
            try {
                ProcessBuilder pb = new ProcessBuilder(
                    "python", preScriptPath, "recover", userReKey, userPrivateKey, uid
                );
                pb.redirectErrorStream(true);
                Process process = pb.start();

                try (BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream(), StandardCharsets.UTF_8))) {
                    String line = reader.readLine();
                    int exitCode = process.waitFor();
                    if (exitCode == 0 && line != null && !line.trim().isEmpty()) {
                        return line.trim();
                    }
                }
            } catch (Exception e) {
                System.err.println("Python PRE recover fallback: " + e.getMessage());
            }
        }
        return ReEncryptionUtil.recoverFileKey(userReKey, userPrivateKey, uid);
    }

    /**
     * Validates, repairs, and normalizes decoded binary files using Python packages (pypdf, python-docx, Pillow).
     */
    public static byte[] normalizeAndVerifyWithPython(byte[] fileBytes, String filename) {
        if (fileBytes == null || fileBytes.length == 0 || filename == null) {
            return fileBytes;
        }

        if (isPythonAvailable() && converterScriptPath != null) {
            try {
                String payloadB64 = Base64.getEncoder().encodeToString(fileBytes);
                String jsonInput = String.format(
                    "{\"filename\":\"%s\",\"payload_b64\":\"%s\"}",
                    filename.replace("\"", "\\\""), payloadB64
                );

                ProcessBuilder pb = new ProcessBuilder("python", converterScriptPath, "process");
                Process process = pb.start();

                try (OutputStream os = process.getOutputStream()) {
                    os.write(jsonInput.getBytes(StandardCharsets.UTF_8));
                    os.flush();
                }

                StringBuilder sb = new StringBuilder();
                try (BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream(), StandardCharsets.UTF_8))) {
                    String line;
                    while ((line = reader.readLine()) != null) {
                        sb.append(line);
                    }
                }

                int exitCode = process.waitFor();
                if (exitCode == 0 && sb.length() > 0) {
                    String outJson = sb.toString();
                    int idx = outJson.indexOf("\"payload_b64\":");
                    if (idx != -1) {
                        int startQuote = outJson.indexOf("\"", idx + 14);
                        int endQuote = outJson.indexOf("\"", startQuote + 1);
                        if (startQuote != -1 && endQuote != -1) {
                            String b64 = outJson.substring(startQuote + 1, endQuote);
                            byte[] processed = Base64.getDecoder().decode(b64);
                            if (processed != null && processed.length > 0) {
                                return processed;
                            }
                        }
                    }
                }
            } catch (Exception e) {
                System.err.println("Python file converter fallback: " + e.getMessage());
            }
        }
        return fileBytes;
    }
}
