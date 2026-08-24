<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.Statement"%>
<%@page import="DBconnection.SQLconnection"%>
<%@page import="java.sql.Connection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // Session Access Guard
    if (session.getAttribute("doid") == null) {
        response.sendRedirect("doLogin.jsp?Auth_Required");
        return;
    }
%>
<%
    String id = request.getParameter("id");
    if (id != null && !id.trim().isEmpty()) {
        Connection con = SQLconnection.getconnection();
        if (con != null) {
            try {
                PreparedStatement p1 = con.prepareStatement("DELETE FROM request WHERE id = ?");
                p1.setString(1, id);
                int i = p1.executeUpdate();
                if (i != 0) {
                    response.sendRedirect("requestedFiles.jsp?Deleted");
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
