<%-- 
    Document   : index
    Created on : 26 Aug, 2024, 4:51:26 PM
    Author     : JAVA-JP
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="DBconnection.SQLconnection"%>
<%@page import="java.sql.Connection"%>
<%
    // Session Access Guard
    if (session.getAttribute("doid") == null) {
        response.sendRedirect("doLogin.jsp?Auth_Required");
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
                        <li><a href="doHome.jsp">Home</a></li>
                        <li><a href="uploadFile.jsp">Upload File</a></li>
                        <li><a style="color:#eb5d1e" href="myFiles.jsp">My Files</a></li>
                        <li><a href="requestedFiles.jsp">Requested Files</a></li>
                        <li><a href="logout.jsp">Logout</a></li>
                    </ul>
                </nav><!-- .nav-menu -->

            </div>
        </header><!-- End Header --><main id="main" style="margin-top: 100px;">

            <!-- ======= About Section ======= -->
            <section id="about" class="about">
                <div class="container" data-aos="fade-up">
                    <div class="row">
                        <div class="col-lg-12 pt-4 pt-lg-0 order-2 order-lg-1 content" data-aos="fade-right" data-aos-delay="100">
                            <center>
                                <h3>My Uploaded Files</h3>
                                <p class="text-muted" style="font-size: 15px; margin-bottom: 20px;">
                                    <i class="icofont-info-circle" style="color: #eb5d1e;"></i> 
                                    Inspect all your uploaded files, block creation timestamps, and Ethereum blockchain transaction hashes.
                                </p>
                            </center><br>

                            <% if (request.getParameter("Deleted") != null) { %>
                                <div class="alert alert-success text-center font-weight-bold" style="font-size: 16px; margin: 15px 0;">
                                    <i class="icofont-check-circled"></i> File Deleted Successfully!
                                </div>
                            <% } %>

                            <table id="customers">
                                <tr>
                                    <th>File ID</th>
                                    <th>File Name</th>
                                    <th>File Keyword</th>
                                    <th>Re-Decryption Key</th>
                                    <th>Uploaded Time</th>
                                    <th>Ethereum TxHash</th>
                                    <th>Action</th>
                                </tr>
                                <%
                                    String doid = (String) session.getAttribute("doid");
                                    String doname = (String) session.getAttribute("doname");
                                    Connection con = SQLconnection.getconnection();
                                    Statement st = con.createStatement();
                                    try {
                                        String sql = "Select * from do_files where doid = '" + doid + "' OR doname = '" + doname + "' ORDER BY id DESC";
                                        if ((doid == null || doid.isEmpty()) && (doname == null || doname.isEmpty())) {
                                            sql = "Select * from do_files ORDER BY id DESC";
                                        }
                                        ResultSet rs = st.executeQuery(sql);
                                        while (rs.next()) {
                                            String txHash = rs.getString("tx_hash");
                                %>
                                <tr>
                                    <td><%=rs.getString("id")%></td>
                                    <td><%=rs.getString("filename")%></td>
                                    <td><%=rs.getString("filekeyword")%></td>
                                    <td>
                                        <code style="font-size:14px; font-weight:bold; color:#0d6efd; background:#e7f1ff; padding:4px 8px; border-radius:4px;"><%=rs.getString("rdkey")%></code>
                                    </td>
                                    <td><%=rs.getString("time")%></td>
                                    <td>
                                        <% if(txHash != null && !txHash.isEmpty()) { %>
                                            <code style="font-size:13px; font-weight:bold; color:#198754; background:#e8f5e9; padding:4px 6px; border-radius:4px;"><%=txHash%></code>
                                        <% } else { %>
                                            <span style="color:#888;">0x... (On-Chain)</span>
                                        <% } %>
                                    </td>
                                    <td>
                                        <a href="deleteFile.jsp?id=<%=rs.getString("id")%>" class="btn btn-sm btn-danger" onclick="return confirm('Are you sure you want to delete this file from cloud storage?');">
                                            <i class="icofont-trash"></i> Delete
                                        </a>
                                    </td>
                                </tr>
                                <%                                        }
                                    } catch (Exception ex) {
                                        ex.printStackTrace();
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
