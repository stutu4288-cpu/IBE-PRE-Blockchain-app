/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package Action;

import DBconnection.SQLconnection;
import Networks.DRIVE_Network;
import com.oreilly.servlet.MultipartRequest;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.sql.SQLException;
import java.security.MessageDigest;
import java.util.Base64;
import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author java4
 */
public class DataUpload extends HttpServlet {

    File file;
    final String filepath = "D:/";

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();
        try {
            HttpSession user = request.getSession(true);
            Object objEnc = user.getAttribute("EncryptText");
            Object objEnc1 = user.getAttribute("EncryptText1");
            Object objTime = user.getAttribute("encryptTime");
            Object objDkey = user.getAttribute("Dkey");
            Object objRDkey = user.getAttribute("RDkey");
            Object objFC = user.getAttribute("filecontent");
            Object objName = user.getAttribute("doname");
            Object objId = user.getAttribute("doid");
            Object objMail = user.getAttribute("domail");
            Object objFname = user.getAttribute("filename");
            Object objFpath = user.getAttribute("filepath");

            String encryptedtext = objEnc != null ? objEnc.toString() : "";
            String encryptedtext1 = objEnc1 != null ? objEnc1.toString() : "";
            String encryptTime = objTime != null ? objTime.toString() : "0";
            String Dkey = objDkey != null ? objDkey.toString() : "";
            String RDkey = objRDkey != null ? objRDkey.toString() : "";
            String filecontent = objFC != null ? objFC.toString() : "";
            String doname = objName != null ? objName.toString() : "DataOwner";
            String doid = objId != null ? objId.toString() : "1";
            String domail = objMail != null ? objMail.toString() : "";
            String fname = objFname != null ? objFname.toString() : "file.txt";
            String fpath = objFpath != null ? objFpath.toString() : "C:/xampp/tomcat/temp/";

            String ori_block1 = user.getAttribute("ori_block1") != null ? user.getAttribute("ori_block1").toString() : "";
            String ori_block2 = user.getAttribute("ori_block2") != null ? user.getAttribute("ori_block2").toString() : "";
            String ori_block3 = user.getAttribute("ori_block3") != null ? user.getAttribute("ori_block3").toString() : "";

            String uploadDir = System.getProperty("java.io.tmpdir");
            if (uploadDir == null || uploadDir.isEmpty()) {
                uploadDir = "C:/xampp/tomcat/temp/";
            }
            File tempDir = new File(uploadDir);
            if (!tempDir.exists()) {
                tempDir.mkdirs();
            }

            MultipartRequest m = new MultipartRequest(request, uploadDir, 100 * 1024 * 1024);
            String keyword = m.getParameter("keyword");
            String paramDoid = m.getParameter("doid");
            String paramDoname = m.getParameter("doname");
            String paramDomail = m.getParameter("domail");

            if (paramDoid != null && !paramDoid.isEmpty() && !paramDoid.equalsIgnoreCase("null")) {
                doid = paramDoid;
            }
            if (paramDoname != null && !paramDoname.isEmpty() && !paramDoname.equalsIgnoreCase("null")) {
                doname = paramDoname;
            }
            if (paramDomail != null && !paramDomail.isEmpty() && !paramDomail.equalsIgnoreCase("null")) {
                domail = paramDomail;
            }

            String block1 = m.getParameter("block1");
            String block2 = m.getParameter("block2");
            String block3 = m.getParameter("block3");
            List<String> list = new ArrayList<>();
            if (block1 != null) list.add(block1);
            if (block2 != null) list.add(block2);
            if (block3 != null) list.add(block3);

            int num = 0;
            String dump = "";
            String dump1 = "";
            String pack = "";
            boolean status = false;

            File splitFolder = new File("C:/xampp/tomcat/temp/Filesplit");
            if (!splitFolder.exists()) {
                splitFolder.mkdirs();
            }

            for (String key : list) {
                num++;
                pack = "\\cloud" + num + "//";
                dump1 = keyword + num;
                dump = splitFolder.getAbsolutePath() + File.separator + dump1 + ".txt";

                try {
                    FileWriter bw = new FileWriter(dump);
                    bw.write(key);
                    bw.close();
                    status = new DRIVE_Network().upload(new File(dump), pack);
                } catch (Exception exDrive) {
                    System.err.println("Cloud drive/file warning: " + exDrive.getMessage());
                }
            }

            byte[] fileBytes = (byte[]) user.getAttribute("fileBytes");
            if (fileBytes == null && !filecontent.isEmpty()) {
                try {
                    fileBytes = Base64.getDecoder().decode(filecontent.replaceAll("\\s+", ""));
                } catch (Exception exB64) {
                    fileBytes = new byte[0];
                }
            }
            if (fileBytes == null) fileBytes = new byte[0];

            byte[] cipherBytes = (byte[]) user.getAttribute("cipherBytes");
            if (cipherBytes == null && !encryptedtext.isEmpty()) {
                try {
                    cipherBytes = Base64.getDecoder().decode(encryptedtext.replaceAll("\\s+", ""));
                } catch (Exception exB64) {
                    cipherBytes = new byte[0];
                }
            }
            if (cipherBytes == null) cipherBytes = new byte[0];

            // SHA-256 cryptographic block integrity hashes
            String hash1 = CryptoUtils.sha256(block1 != null ? block1.getBytes("UTF-8") : new byte[0]);
            String hash2 = CryptoUtils.sha256(block2 != null ? block2.getBytes("UTF-8") : new byte[0]);
            String hash3 = CryptoUtils.sha256(block3 != null ? block3.getBytes("UTF-8") : new byte[0]);

            // Ethereum Blockchain Smart Contract Logging via Ganache
            String txHash = Networks.EthereumBridge.logUploadOnChain(doid, fname, doname, hash1, hash2, hash3);

            DateFormat dateFormat = new SimpleDateFormat("yyyy/MM/dd HH:mm:ss");
            Date date = new Date();
            String time = dateFormat.format(date);

            PreparedStatement pstm = null;
            Connection con = SQLconnection.getconnection();
            if (con != null) {
                try {
                    String query = "insert into do_files (doid, doname, enc_data, dkey, time, filekeyword, filename, data, block1, block2, block3, hash1, hash2, hash3, ori_block1, ori_block2, ori_block3, rdkey, reencrypt_data, encryptTime, tx_hash) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) ";
                    pstm = con.prepareStatement(query);
                    pstm.setString(1, doid);
                    pstm.setString(2, doname);
                    pstm.setBinaryStream(3, new java.io.ByteArrayInputStream(cipherBytes), cipherBytes.length);
                    pstm.setString(4, Dkey);
                    pstm.setString(5, time);
                    pstm.setString(6, keyword);
                    pstm.setString(7, fname);
                    pstm.setBinaryStream(8, new java.io.ByteArrayInputStream(fileBytes), fileBytes.length);
                    pstm.setString(9, block1);
                    pstm.setString(10, block2);
                    pstm.setString(11, block3);
                    pstm.setString(12, hash1);
                    pstm.setString(13, hash2);
                    pstm.setString(14, hash3);
                    pstm.setString(15, ori_block1);
                    pstm.setString(16, ori_block2);
                    pstm.setString(17, ori_block3);
                    pstm.setString(18, RDkey);
                    pstm.setString(19, encryptedtext1);
                    pstm.setString(20, encryptTime);
                    pstm.setString(21, txHash);
                    int row = pstm.executeUpdate();
                    if (row > 0) {
                        response.sendRedirect("uploadFile.jsp?File_uploaded");
                    } else {
                        response.sendRedirect("uploadFile.jsp?Upload_Failed");
                    }

                } catch (SQLException ex) {
                    ex.printStackTrace();
                    response.sendRedirect("uploadFile.jsp?Upload_Failed");
                }
            } else {
                response.sendRedirect("uploadFile.jsp?DB_Error");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("uploadFile.jsp?Error");
        }

    }

    public void split(String FilePath, long splitlen) {
        long leninfile = 0, leng = 0;
        int count = 1, data;
        try {
            File filename = new File(FilePath);
//RandomAccessFile infile = new RandomAccessFile(filename, "r");
            InputStream infile = new BufferedInputStream(new FileInputStream(filename));
            data = infile.read();
            while (data != -1) {
                filename = new File(FilePath + count + ".sp");
//RandomAccessFile outfile = new RandomAccessFile(filename, "rw");
                OutputStream outfile = new BufferedOutputStream(new FileOutputStream(filename));
                while (data != -1 && leng < splitlen) {
                    outfile.write(data);
                    leng++;
                    data = infile.read();
                }
                leninfile += leng;
                leng = 0;
                outfile.close();
                count++;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

    /** SHA-256 cryptographic hash helper — returns lowercase hex string */
    private String sha256(byte[] data) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hashBytes = md.digest(data);
            StringBuilder sb = new StringBuilder();
            for (byte b : hashBytes) sb.append(String.format("%02x", b));
            return sb.toString();
        } catch (Exception e) {
            return "hash-error";
        }
    }
}

