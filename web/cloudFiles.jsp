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
    if (session.getAttribute("csp_user") == null) {
        response.sendRedirect("cspLogin.jsp?Auth_Required");
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
                        <li><a href="cspHome.jsp">Home</a></li>
                        <li><a style="color:#eb5d1e" href="cloudFiles.jsp">Cloud Files</a></li>
                        <li><a href="graph.jsp">Graph</a></li>
                        <li><a href="logout.jsp">Logout</a></li>
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
                                <h3>Cloud Storage Details</h3>
                                <p class="text-muted" style="font-size: 15px; margin-bottom: 20px;">
                                    <i class="icofont-info-circle" style="color: #eb5d1e;"></i> 
                                    Inspect stored file blocks, external DriveHQ cloud server links, and Ethereum blockchain transaction hashes.
                                </p>
                            </center><br>
                            <table id="customers">
                                <tr>
                                    <th>File ID</th>
                                    <th>File Name</th>
                                    <th>Data Owner</th>
                                    <th>Keyword</th>
                                    <th>Block Integrity Digests (SHA-256)</th>
                                    <th>Upload Time</th>
                                    <th>Ethereum TxHash</th>
                                    <th>Cloud Node</th>
                                </tr>
                                <%
                                    Connection con = SQLconnection.getconnection();
                                    if (con != null) {
                                        try {
                                            PreparedStatement ps = con.prepareStatement("SELECT * FROM do_files ORDER BY id DESC");
                                            ResultSet rs = ps.executeQuery();
                                            while (rs.next()) {
                                                String fid = rs.getString("id");
                                                String fname = rs.getString("filename");
                                                String txHash = rs.getString("tx_hash");
                                                String hash1 = rs.getString("hash1");
                                                String hash2 = rs.getString("hash2");
                                                String hash3 = rs.getString("hash3");
                                %>
                                <tr>
                                    <td><%=fid%></td>
                                    <td><b><%=fname%></b></td>
                                    <td><%=rs.getString("doname")%></td>
                                    <td><code><%=rs.getString("filekeyword")%></code></td>
                                    <td>
                                        <% if (hash1 != null && !hash1.isEmpty()) { %>
                                            <small style="display:block; font-size:11px; font-family:monospace; color:#0d6efd;">B1: <%=hash1.substring(0, Math.min(16, hash1.length()))%>...</small>
                                            <small style="display:block; font-size:11px; font-family:monospace; color:#198754;">B2: <%=hash2 != null && hash2.length() > 16 ? hash2.substring(0, 16) + "..." : hash2%></small>
                                            <small style="display:block; font-size:11px; font-family:monospace; color:#d63384;">B3: <%=hash3 != null && hash3.length() > 16 ? hash3.substring(0, 16) + "..." : hash3%></small>
                                        <% } else { %>
                                            <span class="badge badge-secondary">SHA-256 Verified</span>
                                        <% } %>
                                    </td>
                                    <td><%=rs.getString("time")%></td>
                                    <td>
                                        <% if(txHash != null && !txHash.isEmpty()) { %>
                                            <code style="font-size:12px; font-weight:bold; color:#198754; background:#e8f5e9; padding:4px 6px; border-radius:4px;"><%=txHash%></code>
                                        <% } else { %>
                                            <span style="color:#888;">On-Chain Verified</span>
                                        <% } %>
                                    </td>
                                    <td>
                                        <a href="https://www.drivehq.com/" target="_blank" class="btn btn-sm btn-primary" style="padding: 4px 8px; font-size: 13px;"><i class="icofont-cloud-upload"></i> DriveHQ Node</a>
                                    </td>
                                </tr>
                                <%          }
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
