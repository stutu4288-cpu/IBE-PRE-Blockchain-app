<%-- 
    Document   : index
    Created on : 26 Aug, 2024, 4:51:26 PM
    Author     : JAVA-JP
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
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
                        <li><a style="color:#eb5d1e" href="duHome.jsp">Home</a></li>
                        <li><a href="searchFile.jsp">Search File</a></li>
                        <li><a href="downloadFiles.jsp">My Requests & Downloads</a></li>
                        <li><a href="index.jsp">Logout</a></li>
                    </ul>
                </nav><!-- .nav-menu -->

            </div>
        </header><!-- End Header -->

        <main id="main" style="padding-top: 90px;">

            <!-- ======= About Section ======= -->
            <section id="about" class="about py-2">
                <div class="container" data-aos="fade-up">
                    <%
                        String id = (String) session.getAttribute("duid");
                        String name = (String) session.getAttribute("duname");
                        String email = (String) session.getAttribute("dumail");
                    %>
                    <div class="row justify-content-center">
                        <div class="col-lg-10 content text-center" data-aos="fade-right" data-aos-delay="100">
                            <h3 class="mb-3 font-weight-bold text-primary">Welcome <%=name != null ? name.toUpperCase() : "DATA USER"%>!</h3>
                            <div class="card border-0 shadow rounded-lg overflow-hidden mb-4 p-2 bg-white">
                                <img src="assets/img/encryption.jpg?v=10" class="img-fluid w-100 rounded" alt="Data User Encryption Portal" style="max-height: 450px; object-fit: contain; background: #ffffff;" onerror="this.src='${pageContext.request.contextPath}/assets/img/encryption.jpg?v=10';" />
                            </div>
                            
                            <div class="row justify-content-center mt-2">
                                <div class="col-md-5 m-2 p-3 bg-light rounded border text-center shadow-sm">
                                    <h5 style="color:#eb5d1e;">Search Files</h5>
                                    <p class="text-muted small mb-2">Search encrypted cloud files by keyword</p>
                                    <a href="searchFile.jsp" class="btn btn-primary btn-sm px-4">Search Files</a>
                                </div>
                                <div class="col-md-5 m-2 p-3 bg-light rounded border text-center shadow-sm">
                                    <h5 style="color:#eb5d1e;">My Requests & Downloads</h5>
                                    <p class="text-muted small mb-2">Track request statuses & download approved files</p>
                                    <a href="downloadFiles.jsp" class="btn btn-primary btn-sm px-4">My Requests & Downloads</a>
                                </div>
                            </div>

                            <!-- Data User Security & Cryptographic Workflow Cards -->
                            <div class="row mt-4 justify-content-center">
                                <div class="col-md-6 mb-3">
                                    <div class="card shadow-sm border-0 h-100">
                                        <img src="assets/img/proxy_reencryption_flow.png" class="card-img-top" alt="Proxy Re-Encryption Flow" style="max-height: 250px; object-fit: contain; background: #fff; padding: 10px;">
                                        <div class="card-body">
                                            <h5 class="card-title text-primary font-weight-bold">Proxy Re-Encryption Workflow</h5>
                                            <p class="card-text text-muted small">Decryption uses your private key ($SK_B$) and the Proxy Re-Encryption key ($rk_{A \to B}$) generated by Data Owners.</p>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-6 mb-3">
                                    <div class="card shadow-sm border-0 h-100">
                                        <img src="assets/img/security_overview.jpg" class="card-img-top" alt="Security Overview" style="max-height: 250px; object-fit: contain; background: #f8f9fa;">
                                        <div class="card-body">
                                            <h5 class="card-title text-primary font-weight-bold">Decentralized Access Control</h5>
                                            <p class="card-text text-muted small">Every download request and approval is verified against the Ethereum Smart Contract access policy.</p>
                                        </div>
                                    </div>
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
