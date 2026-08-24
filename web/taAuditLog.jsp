<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="DBconnection.SQLconnection"%>
<%@page import="java.sql.Connection"%>
<%
    // Session Access Guard
    if (session.getAttribute("ta_user") == null) {
        response.sendRedirect("taLogin.jsp?Auth_Required");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta content="width=device-width, initial-scale=1.0" name="viewport">
    <title>TA Audit Log - Security Monitor</title>
    <link href="assets/vendor/bootstrap/css/bootstrap.min.css" rel="stylesheet">
    <link href="assets/vendor/icofont/icofont.min.css" rel="stylesheet">
    <link href="assets/css/style.css" rel="stylesheet">
</head>
<body>
    <header id="header" class="fixed-top header-inner-pages">
        <div class="container d-flex align-items-center">
            <h1 class="logo mr-auto"><a href="taHome.jsp">Trusted Authority</a></h1>
            <nav class="nav-menu d-none d-lg-block">
                <ul>
                    <li><a href="taHome.jsp">Home</a></li>
                    <li><a href="dataOwners.jsp">Data Owners</a></li>
                    <li><a href="dataUsers.jsp">Data Users</a></li>
                    <li><a href="reqFiles.jsp">Requested Files</a></li>
                    <li class="active"><a href="taAuditLog.jsp">Login Audit Log</a></li>
                    <li><a href="logout.jsp" style="color: #ff6b6b; font-weight: bold;">Logout</a></li>
                </ul>
            </nav>
        </div>
    </header>

    <main id="main" style="margin-top: 100px;">
        <section class="container">
            <div class="section-title">
                <h2>Security Audit Log</h2>
                <p>Real-time login authentication logs and brute-force monitoring</p>
            </div>
            <div class="table-responsive">
                <table class="table table-bordered table-striped">
                    <thead class="thead-dark">
                        <tr>
                            <th>#</th>
                            <th>User Type</th>
                            <th>Identifier / Email</th>
                            <th>IP Address</th>
                            <th>Timestamp</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
<%
    Connection con = SQLconnection.getconnection();
    if (con != null) {
        try {
            PreparedStatement ps = con.prepareStatement("SELECT * FROM login_log ORDER BY id DESC LIMIT 50");
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                String st = rs.getString("status");
                String badge = "SUCCESS".equalsIgnoreCase(st) ? "badge-success" : "badge-danger";
%>
                        <tr>
                            <td><%= rs.getInt("id") %></td>
                            <td><span class="badge badge-info"><%= rs.getString("user_type") %></span></td>
                            <td><%= rs.getString("email") %></td>
                            <td><%= rs.getString("ip_address") %></td>
                            <td><%= rs.getTimestamp("login_time") %></td>
                            <td><span class="badge <%= badge %>"><%= st %></span></td>
                        </tr>
<%
            }
        } catch (Exception ex) {
            out.println("<tr><td colspan='6' class='text-danger'>Error loading log: " + ex.getMessage() + "</td></tr>");
        }
    }
%>
                    </tbody>
                </table>
            </div>
        </section>
    </main>
</body>
</html>
