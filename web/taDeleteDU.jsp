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
                PreparedStatement p1 = con.prepareStatement("DELETE FROM request WHERE uid = ?");
                p1.setString(1, id);
                p1.executeUpdate();

                PreparedStatement p2 = con.prepareStatement("DELETE FROM du_reg WHERE id = ?");
                p2.setString(1, id);
                int i = p2.executeUpdate();
                if (i != 0) {
                    response.sendRedirect("dataUsers.jsp?Deleted");
                } else {
                    response.sendRedirect("dataUsers.jsp?Failed");
                }
            } catch (Exception ex) {
                ex.printStackTrace();
                response.sendRedirect("dataUsers.jsp?Error");
            }
        } else {
            response.sendRedirect("dataUsers.jsp?DB_Error");
        }
    } else {
        response.sendRedirect("dataUsers.jsp");
    }
%>
