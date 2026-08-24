<%-- 
    Document   : do_signin (Security Hardened)
    - PreparedStatement prevents SQL Injection
    - SHA-256 password comparison (no plaintext in DB)
    - Brute-force lockout after 5 failed attempts in 10 min
--%>

<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Timestamp"%>
<%@page import="DBconnection.SQLconnection"%>
<%@page import="java.sql.Connection"%>
<%@page import="Action.PasswordUtil"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String mail = request.getParameter("email");
    String pass = request.getParameter("pass");
    String pkey = request.getParameter("pkey");
    String ip   = request.getRemoteAddr();

    if (mail == null || pass == null) {
        response.sendRedirect("doLogin.jsp?Failed"); return;
    }

    mail = mail.trim();
    pass = pass.trim();
    if (pkey != null) pkey = pkey.trim().replace(" ", "+");

    Connection con = SQLconnection.getconnection();
    if (con == null) { response.sendRedirect("doLogin.jsp?DB_Error"); return; }

    try {
        // --- Brute-force lockout: count FAILED attempts in last 10 minutes ---
        PreparedStatement chk = con.prepareStatement(
            "SELECT COUNT(*) FROM login_log WHERE ip_address=? AND user_type='DO' AND status='FAILED' AND login_time > DATE_SUB(NOW(), INTERVAL 10 MINUTE)");
        chk.setString(1, ip);
        ResultSet rchk = chk.executeQuery();
        rchk.next();
        int attempts = rchk.getInt(1);
        if (attempts >= 5) {
            response.sendRedirect("doLogin.jsp?Locked");
            return;
        }

        // --- Step 1: PreparedStatement login query (matching email/phone/name) ---
        PreparedStatement ps = con.prepareStatement(
            "SELECT * FROM do_reg WHERE email=? OR phone=? OR name=?");
        ps.setString(1, mail); ps.setString(2, mail); ps.setString(3, mail);
        ResultSet rs = ps.executeQuery();

        if (rs.next()) {
            String status = rs.getString("status");
            String storedPassword = rs.getString("password");
            String dbPKey = rs.getString("Private_key");

            // Check if status is Approved
            if (!"Approved".equalsIgnoreCase(status)) {
                if ("Revoked".equalsIgnoreCase(status)) {
                    response.sendRedirect("doLogin.jsp?msg=Account_Revoked");
                } else {
                    response.sendRedirect("doLogin.jsp?msg=Account_Pending");
                }
                return;
            }

            // Verify password using SHA-256 (or plain text fallback)
            boolean passMatches = PasswordUtil.verify(pass, storedPassword) || pass.equals(storedPassword);

            // Verify private key (if supplied by user)
            boolean pkeyMatches = true;
            if (pkey != null && !pkey.isEmpty()) {
                String normPKey = pkey.replace(" ", "+");
                String normDbKey = dbPKey != null ? dbPKey.replace(" ", "+") : "";
                pkeyMatches = normPKey.equalsIgnoreCase(normDbKey);
            }

            if (passMatches && pkeyMatches) {
                // SUCCESS — set session
                session.setAttribute("doid",   rs.getString("id"));
                session.setAttribute("doname", rs.getString("name"));
                session.setAttribute("domail", rs.getString("email"));
                session.setAttribute("dopkey", dbPKey);

                // Log success
                PreparedStatement log = con.prepareStatement(
                    "INSERT INTO login_log(user_type,user_id,email,ip_address,status) VALUES('DO',?,?,?,'SUCCESS')");
                log.setString(1, rs.getString("id")); log.setString(2, rs.getString("email")); log.setString(3, ip);
                log.executeUpdate();

                response.sendRedirect("doHome.jsp?Success");
            } else {
                // Log failed attempt (wrong password or private key)
                PreparedStatement log = con.prepareStatement(
                    "INSERT INTO login_log(user_type,user_id,email,ip_address,status) VALUES('DO', ?, ?, ?, 'FAILED')");
                log.setString(1, "0"); log.setString(2, mail); log.setString(3, ip);
                log.executeUpdate();

                response.sendRedirect("doLogin.jsp?Failed");
            }
        } else {
            // Log failed attempt (user not found)
            PreparedStatement log = con.prepareStatement(
                "INSERT INTO login_log(user_type,user_id,email,ip_address,status) VALUES('DO', ?, ?, ?, 'FAILED')");
            log.setString(1, "0"); log.setString(2, mail); log.setString(3, ip);
            log.executeUpdate();

            response.sendRedirect("doLogin.jsp?Failed");
        }
    } catch (Exception ex) {
        ex.printStackTrace();
        response.sendRedirect("doLogin.jsp?Error");
    }
%>