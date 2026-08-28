<%-- 
    Document   : index
    Created on : 26 Aug, 2024, 4:51:26 PM
    Author     : JAVA-JP
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="DBconnection.SQLconnection"%>
<%@page import="java.sql.Connection"%>
<%
    // Session Access Guard
    if (session.getAttribute("duid") == null) {
        response.sendRedirect("duLogin.jsp?Auth_Required");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="utf-8">
        <meta content="width=device-width, initial-scale=1.0" name="viewport">

        <title>Proxy Re-Encryption Approach to Secure Data Sharing</title>
        <meta content="" name="description">
        <meta content="" name="keywords">

        <!-- Favicons -->
        <link href="assets/img/favicon.png" rel="icon">
        <link href="assets/img/apple-touch-icon.png" rel="apple-touch-icon">

        <!-- Google Fonts -->
        <link href="https://fonts.googleapis.com/css?family=Open+Sans:300,300i,400,400i,600,600i,700,700i|Raleway:300,300i,400,400i,500,500i,600,600i,700,700i|Poppins:300,300i,400,400i,500,500i,600,600i,700,700i" rel="stylesheet">

        <!-- Vendor CSS Files -->
        <link href="assets/vendor/bootstrap/css/bootstrap.min.css" rel="stylesheet">
        <link href="assets/vendor/icofont/icofont.min.css" rel="stylesheet">
        <link href="assets/vendor/boxicons/css/boxicons.min.css" rel="stylesheet">
        <link href="assets/vendor/owl.carousel/assets/owl.carousel.min.css" rel="stylesheet">
        <link href="assets/vendor/remixicon/remixicon.css" rel="stylesheet">
        <link href="assets/vendor/venobox/venobox.css" rel="stylesheet">
        <link href="assets/vendor/aos/aos.css" rel="stylesheet">

        <!-- Template Main CSS File -->
        <link href="assets/css/style.css" rel="stylesheet">
    </head>
    <style>

        #customers {
            font-family: "Trebuchet MS", Arial, Helvetica, sans-serif;
            font-size: 20px;
            border-collapse: collapse;
            width: 100%;
        }

        #customers td, #customers th {
            border: 2px solid black;
            align:"center";  cellpadding:"0"; cellspacing:"2";
            padding: 15px;
        }


        #customers th {
            padding-top: 12px;
            padding-bottom: 12px;
            text-align: left;
            background-color: #1DA1F2;
            color: white;
        }
    </style>
    <body>

        <!-- ======= Header ======= -->
        <header id="header" class="fixed-top">
            <div class="container-fluid d-flex">

                <div class="logo mr-auto">
                    <h1 class="text-light"><a><span>Re-Encryption</span></a></h1>
                    <!-- Uncomment below if you prefer to use an image logo -->
                    <!-- <a href="index.html"><img src="assets/img/logo.png" alt="" class="img-fluid"></a>-->
                </div>

                <nav class="nav-menu d-none d-lg-block">
                    <ul>
                        <li><a href="duHome.jsp">Home</a></li>
                        <li><a href="searchFile.jsp">Search File</a></li>
                        <li><a style="color:#eb5d1e" href="downloadFiles.jsp">My Requests & Downloads</a></li>
                        <li><a href="index.jsp">Logout</a></li>
                    </ul>
                </nav><!-- .nav-menu -->

            </div>
        </header><!-- End Header -->

        <main id="main" style="margin-top: 100px;">

            <!-- ======= About Section ======= -->
            <section id="about" class="about">
                <div class="container" data-aos="fade-up">
                    <div class="row">
                        <div class="col-lg-12 pt-4 pt-lg-0 order-2 order-lg-1 content" data-aos="fade-right" data-aos-delay="100">
                            <center>
                                <h3>My Requested Files & Approval Status</h3>
                                <p class="text-muted" style="font-size: 15px; margin-bottom: 20px;">
                                    <i class="icofont-info-circle" style="color: #eb5d1e;"></i> 
                                    Track status of all your access requests. Once approved by the Data Owner, use your Re-Encryption key to decrypt and download files.
                                </p>
                            </center><br>
                            <table id="customers">
                                <tr>
                                    <th>Req ID</th>
                                    <th>File Name</th>
                                    <th>Requested Date</th>
                                    <th>Status</th>
                                    <th>Re-Encryption Key</th>
                                    <th>Ethereum TxHash</th>
                                    <th>Action</th>
                                </tr>
                                <%
                                    String uid = (String) session.getAttribute("duid");
                                    Connection con = SQLconnection.getconnection();
                                    boolean hasRequests = false;
                                    if (con != null && uid != null) {
                                        try {
                                            PreparedStatement ps = con.prepareStatement("SELECT * FROM request WHERE uid=? ORDER BY id DESC");
                                            ps.setString(1, uid);
                                            ResultSet rs = ps.executeQuery();
                                            while (rs.next()) {
                                                hasRequests = true;
                                                String status = rs.getString("status");
                                                String dostatus = rs.getString("dostatus");
                                                String rdkey = rs.getString("rdkey");
                                                String txHash = rs.getString("tx_hash");
                                                boolean isApproved = "Approved".equalsIgnoreCase(status) || "Approved".equalsIgnoreCase(dostatus);
                                                boolean isRejected = "Rejected".equalsIgnoreCase(status) || "Rejected".equalsIgnoreCase(dostatus);
                                %>
                                <tr>
                                    <td><%=rs.getString("id")%></td>
                                    <td><b><%=rs.getString("filename")%></b></td>
                                    <td><%=rs.getString("time")%></td>
                                    <td>
                                        <% if(isApproved) { %>
                                            <span class="badge badge-success" style="font-size:14px; padding:6px 10px;"><i class="icofont-check-circled"></i> Approved</span>
                                        <% } else if(isRejected) { %>
                                            <span class="badge badge-danger" style="font-size:14px; padding:6px 10px;"><i class="icofont-close-circled"></i> Rejected</span>
                                        <% } else { %>
                                            <span class="badge badge-warning" style="font-size:14px; padding:6px 10px;"><i class="icofont-clock-time"></i> Pending</span>
                                        <% } %>
                                    </td>
                                    <td>
                                        <% if(isApproved && rdkey != null && !rdkey.isEmpty() && !"waiting".equalsIgnoreCase(rdkey)) { %>
                                            <code style="font-size:14px; font-weight:bold; color:#0d6efd; background:#e7f1ff; padding:4px 8px; border-radius:4px; word-break:break-all;"><%=rdkey%></code>
                                        <% } else { %>
                                            <span class="text-muted"><i class="icofont-lock"></i> Hidden until Approved</span>
                                        <% } %>
                                    </td>
                                    <td>
                                        <% if(txHash != null && !txHash.isEmpty() && !txHash.equalsIgnoreCase("null")) { %>
                                            <code style="font-size:13px; font-weight:bold; color:#198754; background:#e8f5e9; padding:4px 6px; border-radius:4px; word-break:break-all;"><%=txHash%></code>
                                        <% } else { %>
                                            <span class="text-muted">N/A</span>
                                        <% } %>
                                    </td>
                                    <td>
                                        <% if(isApproved) { %>
                                            <a href="verify.jsp?rid=<%=rs.getString("id")%>" class="btn btn-success btn-sm font-weight-bold"><i class="icofont-download"></i> Download File</a>
                                        <% } else if(isRejected) { %>
                                            <button disabled class="btn btn-danger btn-sm font-weight-bold" style="opacity:0.75; cursor:not-allowed;"><i class="icofont-close"></i> Denied</button>
                                        <% } else { %>
                                            <button disabled class="btn btn-secondary btn-sm" style="opacity:0.75; cursor:not-allowed;"><i class="icofont-clock-time"></i> Pending Approval</button>
                                        <% } %>
                                    </td>
                                </tr>
                                <%          }
                                            if (!hasRequests) {
                                                out.println("<tr><td colspan='7' class='text-center text-muted py-4' style='font-size:16px;'><i class='icofont-info-circle' style='color:#eb5d1e;'></i> You have not submitted any file access requests yet. <a href='searchFile.jsp' class='btn btn-primary btn-sm ml-2'>Search & Request Files</a></td></tr>");
                                            }
                                        } catch (Exception ex) {
                                            ex.printStackTrace();
                                        }
                                    }
                                %>
                            </table>
                        </div>
                    </div>

                </div>
            </section><!-- End About Section -->

        </main><!-- End #main -->

        <!-- ======= Footer ======= -->
        <footer id="footer">
            <div class="container py-4">
                <center>&copy;  <strong><span>2026</span></strong>.</center>
            </div>
        </footer><!-- End Footer -->

        <a href="#" class="back-to-top"><i class="icofont-simple-up"></i></a>

        <!-- Vendor JS Files -->
        <script src="assets/vendor/jquery/jquery.min.js"></script>
        <script src="assets/vendor/bootstrap/js/bootstrap.bundle.min.js"></script>
        <script src="assets/vendor/jquery.easing/jquery.easing.min.js"></script>
        <script src="assets/vendor/php-email-form/validate.js"></script>
        <script src="assets/vendor/owl.carousel/owl.carousel.min.js"></script>
        <script src="assets/vendor/waypoints/jquery.waypoints.min.js"></script>
        <script src="assets/vendor/counterup/counterup.min.js"></script>
        <script src="assets/vendor/isotope-layout/isotope.pkgd.min.js"></script>
        <script src="assets/vendor/venobox/venobox.min.js"></script>
        <script src="assets/vendor/aos/aos.js"></script>

        <!-- Template Main JS File -->
        <script src="assets/js/main.js"></script>

    </body>

</html>
