/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package Action;

/**
 *
 * @author JAVA-JP
 */
import DBconnection.SQLconnection;
import com.oreilly.servlet.MultipartRequest;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.Statement;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Base64;
import java.util.Date;
import javax.crypto.KeyGenerator;
import javax.crypto.SecretKey;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 *
 * @author java3
 */
public class Upload extends HttpServlet {

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    File file;

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();
        try {
            String filepath = System.getProperty("java.io.tmpdir");
            if (filepath == null || filepath.isEmpty()) {
                filepath = "C:/xampp/tomcat/temp/";
            }
            File tempDir = new File(filepath);
            if (!tempDir.exists()) {
                tempDir.mkdirs();
            }
            MultipartRequest m = new MultipartRequest(request, filepath, 100 * 1024 * 1024);
            String filekeyword = m.getParameter("keyword");
            File file = m.getFile("fileToUpload");
            if (file == null) {
                java.util.Enumeration files = m.getFileNames();
                if (files != null && files.hasMoreElements()) {
                    String fNameKey = (String) files.nextElement();
                    file = m.getFile(fNameKey);
                }
            }
            if (file == null || !file.exists()) {
                response.sendRedirect("uploadFile.jsp?msg=Upload_File_Not_Found");
                return;
            }
            String filename = file.getName();

            byte[] fileBytes = java.nio.file.Files.readAllBytes(file.toPath());
            String origHash = CryptoUtils.sha256(fileBytes);
            String rawBase64Content = Base64.getEncoder().encodeToString(fileBytes);

            KeyGenerator Attrib_key = KeyGenerator.getInstance("AES");
            Attrib_key.init(128);
            SecretKey secretKey = Attrib_key.generateKey();

            Encryption e = new Encryption();
            byte[] encBytes = e.encryptGCM(fileBytes, secretKey);
            String encryptedtext = Base64.getEncoder().encodeToString(encBytes);

            byte[] b = secretKey.getEncoded();
            String Dkey = Base64.getEncoder().encodeToString(b);

            KeyGenerator Attrib_key1 = KeyGenerator.getInstance("AES");
            Attrib_key1.init(128);
            SecretKey secretKey1 = Attrib_key1.generateKey();

            long aTime = System.nanoTime();
            
            Encryption e1 = new Encryption();
            byte[] encBytes1 = e1.encryptGCM(fileBytes, secretKey1);
            String encryptedtext1 = Base64.getEncoder().encodeToString(encBytes1);
            
            long bTime = System.nanoTime();
            float encryptTime = (float)(bTime - aTime) / 1000;
            
            byte[] b1 = secretKey1.getEncoded();
            String RDkey = Base64.getEncoder().encodeToString(b1);

            HttpSession user = request.getSession(true);
            String doname = user.getAttribute("doname") != null ? user.getAttribute("doname").toString() : "DataOwner";
            String doid = user.getAttribute("doid") != null ? user.getAttribute("doid").toString() : "1";

            DateFormat dateFormat = new SimpleDateFormat("yyyy/MM/dd HH:mm:ss");
            Date date = new Date();
            String time = dateFormat.format(date);

            Connection con = SQLconnection.getconnection();
            PreparedStatement pstm = con.prepareStatement(
                "insert into do_files(doid, doname, data_file, dkey, time, filename, data, filekeyword, reencrypt_file, rdkey, hashcode, enc_time, enc_data, reencrypt_data) values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
            pstm.setString(1, doid);
            pstm.setString(2, doname);
            pstm.setBinaryStream(3, new java.io.ByteArrayInputStream(encBytes), encBytes.length);
            pstm.setString(4, Dkey);
            pstm.setString(5, time);
            pstm.setString(6, file.getName());
            pstm.setBinaryStream(7, new java.io.ByteArrayInputStream(fileBytes), fileBytes.length);
            pstm.setString(8, filekeyword);
            pstm.setBinaryStream(9, new java.io.ByteArrayInputStream(encBytes1), encBytes1.length);
            pstm.setString(10, RDkey);
            pstm.setInt(11, origHash.hashCode());
            pstm.setFloat(12, encryptTime);
            pstm.setBinaryStream(13, new java.io.ByteArrayInputStream(encBytes), encBytes.length);
            pstm.setBinaryStream(14, new java.io.ByteArrayInputStream(encBytes1), encBytes1.length);

            int i = pstm.executeUpdate();
            if (i != 0) {
                response.sendRedirect("uploadFile.jsp?File_uploaded");
            } else {
                response.sendRedirect("uploadFile.jsp?Upload_Failed");
            }
        } catch (Exception e) {
            out.println(e);
        } finally {
            out.close();
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
}
