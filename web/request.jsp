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
            // Check if request already exists for this user and file
            PreparedStatement psChk = con.prepareStatement("SELECT id FROM request WHERE uid=? AND fid=?");
            psChk.setString(1, uid);
            psChk.setString(2, fid.trim());
            ResultSet rsChk = psChk.executeQuery();
            if (rsChk.next()) {
                response.sendRedirect("searchAction.jsp?Already_Requested=true");
                return;
            }

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
                    "INSERT INTO request(filename, time, uid, uname, status, fid, doid, umail, dkey, rdkey, dostatus) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
                psIns.setString(1, fname);
                psIns.setString(2, time);
                psIns.setString(3, uid);
                psIns.setString(4, uname);
                psIns.setString(5, "waiting");
                psIns.setString(6, fid.trim());
                psIns.setString(7, doid);
                psIns.setString(8, umail);
                psIns.setString(9, dkey);
                psIns.setString(10, userRdkey);
                psIns.setString(11, "waiting");

                int i = psIns.executeUpdate();
                if (i != 0) {
                    response.sendRedirect("searchAction.jsp?Requestsent=true");
                } else {
                    response.sendRedirect("searchAction.jsp?failed=true");
                }
            } else {
                response.sendRedirect("searchAction.jsp?failed=true");
            }
        } catch (Exception ex) {
            ex.printStackTrace();
            response.sendRedirect("searchAction.jsp?failed=true");
        }
    } else {
        response.sendRedirect("searchAction.jsp?DB_Error=true");
    }
%>


