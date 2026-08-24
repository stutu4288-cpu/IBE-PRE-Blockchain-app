<%@page import="Networks.Mail"%>
<%@page import="Action.PasswordUtil"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="DBconnection.SQLconnection"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.security.SecureRandom"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String email = request.getParameter("email");
    String role  = request.getParameter("role");

    if (email != null && !email.trim().isEmpty()) {
        Connection con = SQLconnection.getconnection();
        if (con != null) {
            try {
                boolean isOwner = "owner".equalsIgnoreCase(role);
                String table  = isOwner ? "do_reg" : "du_reg";
                String keyCol = isOwner ? "Private_key" : "private_key";

                // PreparedStatement query (SQL-injection safe)
                PreparedStatement ps = con.prepareStatement(
                    "SELECT id, name, email, " + keyCol + " FROM " + table + " WHERE email=? AND status='Approved'");
                ps.setString(1, email.trim());
                ResultSet rs = ps.executeQuery();

                if (rs.next()) {
                    String id   = rs.getString("id");
                    String name = rs.getString("name");
                    String pkey = rs.getString(keyCol);

                    // Generate a new 8-character temporary password
                    int randomNum = 1000 + new SecureRandom().nextInt(9000);
                    String tempPass = "Pass-" + randomNum;
                    String hashedTempPass = PasswordUtil.hash(tempPass);

                    // Update DB with the new hashed temporary password
                    PreparedStatement upd = con.prepareStatement(
                        "UPDATE " + table + " SET password=? WHERE id=?");
                    upd.setString(1, hashedTempPass);
                    upd.setString(2, id);
                    upd.executeUpdate();

                    // Store temporary pass & private key in session for display alert
                    session.setAttribute("tempPass", tempPass);
                    session.setAttribute("tempPkey", pkey);

                    String msg = "Hello " + name + ",\n\n"
                            + "Your password has been successfully reset for the Proxy Re-Encryption Data Sharing Portal:\n\n"
                            + "Email: " + email + "\n"
                            + "New Temporary Password: " + tempPass + "\n"
                            + "Identity Private Key: " + pkey + "\n\n"
                            + "Please log in and keep your Private Key secure.\n\n"
                            + "Regards,\nSecurity Operations Team";

                    // Send email notification
                    Mail.secretMail(msg, name, email);

                    response.sendRedirect("forgotPassword.jsp?Sent");
                } else {
                    response.sendRedirect("forgotPassword.jsp?NotFound");
                }
            } catch (Exception ex) {
                ex.printStackTrace();
                response.sendRedirect("forgotPassword.jsp?Error");
            }
        } else {
            response.sendRedirect("forgotPassword.jsp?DB_Error");
        }
    } else {
        response.sendRedirect("forgotPassword.jsp");
    }
%>

