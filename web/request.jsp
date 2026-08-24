<%-- 
    Document   : DO_login
    Created on : 9 Mar, 2024, 5:34:14 PM
    Author     : JAVA-JP
--%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="DBconnection.SQLconnection"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.text.DateFormat"%>
<%@page import="java.util.Date"%>
<%@page import="Action.ReEncryptionUtil"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String fid = request.getParameter("fid");
    String uid = (String) session.getAttribute("duid");
    String uname = (String) session.getAttribute("duname");
    String umail = (String) session.getAttribute("dumail");

    if (fid == null || fid.trim().isEmpty() || uid == null) {
        response.sendRedirect("searchFile.jsp?failed");
        return;
    }

    Connection con = SQLconnection.getconnection();
    if (con != null) {
        try {
            // 1. Fetch requesting Data User's identity private key
            String userPKey = "DEFAULT_KEY";
            PreparedStatement psUser = con.prepareStatement("SELECT private_key FROM du_reg WHERE id=?");
            psUser.setString(1, uid);
            ResultSet rsUser = psUser.executeQuery();
            if (rsUser.next()) {
                userPKey = rsUser.getString("private_key");
            }

            // 2. Fetch file master key & details
            PreparedStatement psFile = con.prepareStatement("SELECT * FROM do_files WHERE id=?");
            psFile.setString(1, fid.trim());
            ResultSet rsFile = psFile.executeQuery();

            if (rsFile.next()) {
                String fname = rsFile.getString("filename");
                String doid  = rsFile.getString("doid");
                String dkey  = rsFile.getString("dkey");

                // 3. Derive UNIQUE user-specific Re-Decryption Key (rdkey_u) combining symmetric file key + asymmetric user key
                String userRdkey = ReEncryptionUtil.deriveUserReKey(dkey, userPKey, uid);

                DateFormat dateFormat = new SimpleDateFormat("yyyy/MM/dd HH:mm:ss");
                String time = dateFormat.format(new Date());

                // 4. Insert request record with user-specific rdkey using PreparedStatement
                PreparedStatement psIns = con.prepareStatement(
                    "INSERT INTO request(filename, time, uid, uname, status, fid, doid, umail, dkey, rdkey, dostatus) VALUES(?, ?, ?, ?, 'waiting', ?, ?, ?, ?, ?, 'waiting')");
                psIns.setString(1, fname);
                psIns.setString(2, time);
                psIns.setString(3, uid);
                psIns.setString(4, uname);
                psIns.setString(5, fid.trim());
                psIns.setString(6, doid);
                psIns.setString(7, umail);
                psIns.setString(8, dkey);
                psIns.setString(9, userRdkey);

                int i = psIns.executeUpdate();
                if (i != 0) {
                    response.sendRedirect("searchFile.jsp?Requestsent");
                } else {
                    response.sendRedirect("searchFile.jsp?failed");
                }
            } else {
                response.sendRedirect("searchFile.jsp?failed");
            }
        } catch (Exception ex) {
            ex.printStackTrace();
            response.sendRedirect("searchFile.jsp?failed");
        }
    } else {
        response.sendRedirect("searchFile.jsp?DB_Error");
    }
%>


