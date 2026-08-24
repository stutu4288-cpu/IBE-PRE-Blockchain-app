<%-- 
    Document   : access_grant
    Created on : sept 30 , 2020, 5:14:44 AM
    Author     : Lenovo
--%>

<%@page import="java.sql.PreparedStatement"%>
<%@page import="Networks.Mail"%>
<%@page import="DBconnection.SQLconnection"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.ResultSet"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // Session Access Guard — Trusted Authority
    if (session.getAttribute("ta_user") == null) {
        response.sendRedirect("taLogin.jsp?Auth_Required");
        return;
    }
%>
<%
    String id = request.getParameter("id");
    if (id != null && !id.trim().isEmpty()) {
        Connection con = SQLconnection.getconnection();
        if (con != null) {
            try {
                PreparedStatement psUpd = con.prepareStatement("UPDATE du_reg SET status='Approved' WHERE id=?");
                psUpd.setString(1, id.trim());
                int i = psUpd.executeUpdate();

                if (i != 0) {
                    PreparedStatement psSel = con.prepareStatement("SELECT * FROM du_reg WHERE id=?");
                    psSel.setString(1, id.trim());
                    ResultSet rs = psSel.executeQuery();
                    if (rs.next()) {
                        String name = rs.getString("name");
                        String mail = rs.getString("email");
                        String private_key = rs.getString("private_key");
                        String msggg = "Hi " + name + ",\n\nYour Data User Registration has been Approved.\nPrivate Key: " + private_key;
                        Mail.secretMail(msggg, name, mail);
                    }
                    response.sendRedirect("dataUsers.jsp?Approved");
                } else {
                    response.sendRedirect("dataUsers.jsp?Failed");
                }
            } catch (Exception ex) {
                ex.printStackTrace();
                response.sendRedirect("dataUsers.jsp?Failed");
            }
        } else {
            response.sendRedirect("dataUsers.jsp?DB_Error");
        }
    } else {
        response.sendRedirect("dataUsers.jsp");
    }
%>
