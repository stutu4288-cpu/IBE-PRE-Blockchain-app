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
                // Delete associated requests first
                PreparedStatement p1 = con.prepareStatement("DELETE FROM request WHERE fid = ?");
                p1.setString(1, id);
                p1.executeUpdate();

                // Delete file record from do_files
                PreparedStatement p2 = con.prepareStatement("DELETE FROM do_files WHERE id = ?");
                p2.setString(1, id);
                int i = p2.executeUpdate();
                if (i != 0) {
                    response.sendRedirect("myFiles.jsp?Deleted");
                } else {
                    response.sendRedirect("myFiles.jsp?Failed");
                }
            } catch (Exception ex) {
                ex.printStackTrace();
                response.sendRedirect("myFiles.jsp?Error");
            }
        } else {
            response.sendRedirect("myFiles.jsp?DB_Error");
        }
    } else {
        response.sendRedirect("myFiles.jsp");
    }
%>
