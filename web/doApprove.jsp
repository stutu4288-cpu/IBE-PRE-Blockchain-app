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
                PreparedStatement psUpd = con.prepareStatement("UPDATE do_reg SET status='Approved' WHERE id=?");
                psUpd.setString(1, id.trim());
                int i = psUpd.executeUpdate();

                if (i != 0) {
                    PreparedStatement psSel = con.prepareStatement("SELECT * FROM do_reg WHERE id=?");
                    psSel.setString(1, id.trim());
                    ResultSet rs = psSel.executeQuery();
                    if (rs.next()) {
                        String name = rs.getString("name");
                        String mail = rs.getString("email");
                        String private_key = rs.getString("Private_key");
                        String msggg = "Hi " + name + ",\n\nYour Data Owner Registration has been Approved.\nPrivate Key: " + private_key;
                        Mail.secretMail(msggg, name, mail);
                    }
                    response.sendRedirect("dataOwners.jsp?Approved");
                } else {
                    response.sendRedirect("dataOwners.jsp?Failed");
                }
            } catch (Exception ex) {
                ex.printStackTrace();
                response.sendRedirect("dataOwners.jsp?Failed");
            }
        } else {
            response.sendRedirect("dataOwners.jsp?DB_Error");
        }
    } else {
        response.sendRedirect("dataOwners.jsp");
    }
%>
