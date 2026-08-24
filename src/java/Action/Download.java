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
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 *
 * @author java1
 */
/**
 *
 * @author Lenovo
 */
@WebServlet("/download")
public class Download extends HttpServlet {

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */

            String fileid = request.getParameter("fid");
            String filename = request.getParameter("filename");
            String rdkey = request.getParameter("rdkey");

            HttpSession user = request.getSession(false);
            if (user == null || user.getAttribute("duid") == null) {
                response.sendRedirect("duLogin.jsp?Auth_Required");
                return;
            }
            String uid   = user.getAttribute("duid").toString();
            String uname = user.getAttribute("duname") != null ? user.getAttribute("duname").toString() : "User";
            String umail = user.getAttribute("dumail") != null ? user.getAttribute("dumail").toString() : "";

            Connection conn = SQLconnection.getconnection();
            Statement st = conn.createStatement();
            Statement st1 = conn.createStatement();
            Statement st2 = conn.createStatement();

            PreparedStatement psReq = conn.prepareStatement(
                "SELECT * FROM request WHERE fid=? AND uid=? AND status='Approved' AND rdkey=?");
            psReq.setString(1, fileid);
            psReq.setString(2, uid);
            psReq.setString(3, rdkey);
            ResultSet rs = psReq.executeQuery();

            if (rs.next()) {
                // Fetch user's identity private key
                String userPKey = "DEFAULT_KEY";
                PreparedStatement psUser = conn.prepareStatement("SELECT private_key FROM du_reg WHERE id=?");
                psUser.setString(1, uid);
                ResultSet rsUser = psUser.executeQuery();
                if (rsUser.next()) {
                    userPKey = rsUser.getString("private_key");
                }

                // Fetch file payload and master encryption key from do_files
                PreparedStatement psFile = conn.prepareStatement("SELECT * FROM do_files WHERE id=?");
                psFile.setString(1, fileid);
                ResultSet rs1 = psFile.executeQuery();

                if (rs1.next()) {
                    String doid   = rs1.getString("doid");
                    String doname = rs1.getString("doname");
                    String file   = rs1.getString("enc_data");
                    if (file == null || file.isEmpty()) file = rs1.getString("reencrypt_data");
                    String dkey   = rs1.getString("dkey");

                    long aTime = System.nanoTime();
                    Decryption d1 = new Decryption();

                    // Recover master file key using user's unique Re-Decryption key + user identity key
                    String recoveredFileKey = ReEncryptionUtil.recoverFileKey(rdkey, userPKey, uid);
                    String decrypted = d1.decrypt(file, recoveredFileKey);

                    // Fallback to direct rdkey or dkey if needed
                    if (decrypted == null) {
                        decrypted = d1.decrypt(file, rdkey);
                    }
                    if (decrypted == null) {
                        decrypted = d1.decrypt(file, dkey);
                    }

                    long bTime = System.nanoTime();
                    float decryptTime = (float)(bTime - aTime) / 1000;

                    if (decrypted == null) decrypted = "";

                    response.setHeader("Content-Disposition", "attachment;filename=\"" + filename + "\"");
                    out.write(decrypted);
                    out.close();

                    PreparedStatement psLog = conn.prepareStatement(
                        "INSERT INTO download (uid, uname, filename, time, fileid, doname, doid, decrypt_time) VALUES (?, ?, ?, NOW(), ?, ?, ?, ?)");
                    psLog.setString(1, uid);
                    psLog.setString(2, uname);
                    psLog.setString(3, filename);
                    psLog.setString(4, fileid);
                    psLog.setString(5, doname);
                    psLog.setString(6, doid);
                    psLog.setFloat(7, decryptTime);
                    psLog.executeUpdate();

                } else {
                    System.out.println("File not found in do_files...");
                    response.sendRedirect("downloadFiles.jsp?File_Not_Found");
                }
            } else {
                response.sendRedirect("downloadFiles.jsp?Access_Not_Approved");
            }

        } catch (SQLException ex) {
            ex.printStackTrace();
            response.sendRedirect("Requested_files.jsp?download_failed");
        } catch (IOException ex) {
            ex.printStackTrace();
            response.sendRedirect("Requested_files.jsp?download_failed");
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
