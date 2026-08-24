<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="DBconnection.SQLconnection"%>
<%@page import="java.sql.Connection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String id = request.getParameter("id");
    String newStatus = request.getParameter("status");
    if (id != null && !id.trim().isEmpty()) {
        Connection con = SQLconnection.getconnection();
        if (con != null) {
            try {
                if (newStatus == null || newStatus.isEmpty()) {
                    PreparedStatement p1 = con.prepareStatement("SELECT status FROM do_reg WHERE id = ?");
                    p1.setString(1, id);
                    ResultSet rs = p1.executeQuery();
                    if (rs.next()) {
                        String cur = rs.getString("status");
                        newStatus = "Approved".equalsIgnoreCase(cur) ? "Revoked" : "Approved";
                    } else {
                        newStatus = "Approved";
                    }
                }
                PreparedStatement p2 = con.prepareStatement("UPDATE do_reg SET status = ? WHERE id = ?");
                p2.setString(1, newStatus);
                p2.setString(2, id);
                int i = p2.executeUpdate();
                if (i != 0) {
                    response.sendRedirect("dataOwners.jsp?Updated");
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
