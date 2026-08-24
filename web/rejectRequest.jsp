<%-- 
    Document   : AccessRequest
    Created on : Sep 20, 2020, 5:17:36 AM
    Author     : Lenovo
--%>

<%@page import="java.sql.PreparedStatement"%>
<%@page import="DBconnection.SQLconnection"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.Connection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // Session Access Guard — Data Owner
    if (session.getAttribute("doid") == null) {
        response.sendRedirect("doLogin.jsp?Auth_Required");
        return;
    }
%>
<%
    String fid = request.getParameter("fid");
    if (fid != null && !fid.trim().isEmpty()) {
        Connection con = SQLconnection.getconnection();
        if (con != null) {
            try {
                PreparedStatement ps = con.prepareStatement(
                    "UPDATE request SET dostatus='Rejected', status='Rejected' WHERE id=?");
                ps.setString(1, fid.trim());
                int i = ps.executeUpdate();
                if (i != 0) {
                    response.sendRedirect("requestedFiles.jsp?Rejected");
                } else {
                    response.sendRedirect("requestedFiles.jsp?Failed");
                }
            } catch (Exception ex) {
                ex.printStackTrace();
                response.sendRedirect("requestedFiles.jsp?Error");
            }
        } else {
            response.sendRedirect("requestedFiles.jsp?DB_Error");
        }
    } else {
        response.sendRedirect("requestedFiles.jsp");
    }
%>
