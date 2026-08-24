<%-- 
    Logout handler: invalidates session and redirects safely
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    if (session != null) {
        session.invalidate();
    }
    response.sendRedirect("index.jsp?LoggedOut");
%>
