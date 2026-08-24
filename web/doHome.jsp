<%-- 
    Document   : index
    Created on : 26 Aug, 2024, 4:51:26 PM
    Author     : JAVA-JP
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
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
    <%
        if (request.getParameter("Success") != null) {
    %>
    <script>alert('Login Successfully');</script>
    <%            }
    %>
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
                        <li><a style="color:#eb5d1e" href="doHome.jsp">Home</a></li>
                        <li><a href="uploadFile.jsp">Upload File</a></li>
                        <li><a href="myFiles.jsp">My Files</a></li>
                        <li><a href="requestedFiles.jsp">Requested Files</a></li>
                        <li><a href="logout.jsp">Logout</a></li>
                    </ul>
                </nav><!-- .nav-menu -->

            </div>
        </header><!-- End Header -->

        <main id="main" style="padding-top: 90px;">

            <!-- ======= About Section ======= -->
            <section id="about" class="about py-2">
                <div class="container" data-aos="fade-up">
                    <%
                        String id = (String) session.getAttribute("doid");
                        String name = (String) session.getAttribute("doname");
                        String email = (String) session.getAttribute("domail");
                    %>
                    <div class="row">
                        <div class="col-lg-12 content text-center" data-aos="fade-right" data-aos-delay="100">
                            <h3 class="mb-2">Welcome <%=name != null ? name.toUpperCase() : "DATA OWNER"%>!</h3>
                            <img src="assets/img/dohome.jpg" class="img-fluid rounded shadow mb-3" style="max-width: 680px; max-height: 340px; width: 100%; height: auto;" />
                            
                            <div class="row justify-content-center mt-2">
                                <div class="col-md-3 m-2 p-3 bg-light rounded border text-center">
                                    <h5 style="color:#eb5d1e;">Upload File</h5>
                                    <p class="text-muted small mb-2">Encrypt & upload file blocks</p>
                                    <a href="uploadFile.jsp" class="btn btn-primary btn-sm">Upload File</a>
                                </div>
                                <div class="col-md-3 m-2 p-3 bg-light rounded border text-center">
                                    <h5 style="color:#eb5d1e;">My Files</h5>
                                    <p class="text-muted small mb-2">Manage uploaded file blocks</p>
                                    <a href="myFiles.jsp" class="btn btn-primary btn-sm">My Files</a>
                                </div>
                                <div class="col-md-3 m-2 p-3 bg-light rounded border text-center">
                                    <h5 style="color:#eb5d1e;">Requested Files</h5>
                                    <p class="text-muted small mb-2">Manage user download requests</p>
                                    <a href="requestedFiles.jsp" class="btn btn-primary btn-sm">Requests</a>
                                </div>
                            </div>
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
