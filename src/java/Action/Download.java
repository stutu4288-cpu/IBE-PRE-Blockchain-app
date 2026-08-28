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
        try {
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

            Connection conn = SQLconnection.getconnection();

            PreparedStatement psReq = conn.prepareStatement(
                "SELECT * FROM request WHERE fid=? AND uid=? AND status='Approved' AND rdkey=?");
            psReq.setString(1, fileid);
            psReq.setString(2, uid);
            psReq.setString(3, rdkey);
            ResultSet rs = psReq.executeQuery();

            if (rs.next()) {
                String userPKey = "DEFAULT_KEY";
                PreparedStatement psUser = conn.prepareStatement("SELECT private_key FROM du_reg WHERE id=?");
                psUser.setString(1, uid);
                ResultSet rsUser = psUser.executeQuery();
                if (rsUser.next()) {
                    userPKey = rsUser.getString("private_key");
                }

                PreparedStatement psFile = conn.prepareStatement("SELECT * FROM do_files WHERE id=?");
                psFile.setString(1, fileid);
                ResultSet rs1 = psFile.executeQuery();

                if (rs1.next()) {
                    String doid   = rs1.getString("doid");
                    String doname = rs1.getString("doname");

                    // Utilize FileEncodingManager to gather, normalize, decrypt, and verify the file
                    FileEncodingManager.DecodedFileResult fileResult = FileEncodingManager.prepareFileForDownload(rs1, rdkey, userPKey, uid);

                    if (fileResult.getLength() == 0) {
                        response.sendRedirect("downloadFiles.jsp?File_Empty_Or_Corrupt");
                        return;
                    }

                    // Log download event in DB before touching the output stream
                    try {
                        PreparedStatement psLog = conn.prepareStatement(
                            "INSERT INTO download (uid, uname, filename, time, fileid, doname, doid, decrypt_time) VALUES (?, ?, ?, NOW(), ?, ?, ?, ?)");
                        psLog.setString(1, uid);
                        psLog.setString(2, uname);
                        psLog.setString(3, filename);
                        psLog.setString(4, fileid);
                        psLog.setString(5, doname);
                        psLog.setString(6, doid);
                        psLog.setFloat(7, fileResult.getProcessingTimeMs());
                        psLog.executeUpdate();
                    } catch (Exception exLog) {
                        System.err.println("Download audit log warning: " + exLog.getMessage());
                    }

                    // Safely stream the pristine decoded binary to the HTTP response
                    FileEncodingManager.streamToClient(response, fileResult);
                    return;

                } else {
                    response.sendRedirect("downloadFiles.jsp?File_Not_Found");
                    return;
                }
            } else {
                response.sendRedirect("downloadFiles.jsp?Access_Not_Approved");
                return;
            }

        } catch (Exception ex) {
            ex.printStackTrace();
            if (!response.isCommitted()) {
                response.sendRedirect("downloadFiles.jsp?download_failed");
            }
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
