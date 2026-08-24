<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.Statement"%>
<%@page import="DBconnection.SQLconnection"%>
<%@page import="java.sql.Connection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String id = request.getParameter("id");
    if (id != null && !id.trim().isEmpty()) {
        Connection con = SQLconnection.getconnection();
        if (con != null) {
            try {
                PreparedStatement p1 = con.prepareStatement("DELETE FROM request WHERE doid = ?");
                p1.setString(1, id);
                p1.executeUpdate();

                PreparedStatement p2 = con.prepareStatement("DELETE FROM do_files WHERE doid = ?");
                p2.setString(1, id);
                p2.executeUpdate();

                PreparedStatement p3 = con.prepareStatement("DELETE FROM do_reg WHERE id = ?");
                p3.setString(1, id);
                int i = p3.executeUpdate();
                if (i != 0) {
                    response.sendRedirect("dataOwners.jsp?Deleted");
                } else {
                    response.sendRedirect("dataOwners.jsp?Failed");
                }
            } catch (Exception ex) {
                ex.printStackTrace();
                response.sendRedirect("dataOwners.jsp?Error");
            }
        } else {
            response.sendRedirect("dataOwners.jsp?DB_Error");
        }
    } else {
        response.sendRedirect("dataOwners.jsp");
    }
%>
