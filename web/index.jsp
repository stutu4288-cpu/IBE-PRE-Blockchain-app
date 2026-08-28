<%-- 
    Document   : index
    Created on : 26 Aug, 2024, 4:51:26 PM
    Author     : JAVA-JP
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
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

    <body class="home-page">

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
                        <li><a style="color:#eb5d1e" href="index.jsp">Home</a></li>
                        <li><a href="doLogin.jsp">Data Owner</a></li>
                        <li><a href="duLogin.jsp">Data user</a></li>
                        <li><a href="taLogin.jsp">Trusted Authority</a></li>
                        <li><a href="proxyLogin.jsp">Proxy Server</a></li>
                        <li><a href="cspLogin.jsp">CSP</a></li>
                    </ul>
                </nav><!-- .nav-menu -->

            </div>
        </header><!-- End Header -->

        <!-- ======= Hero Section ======= -->
        <section id="hero" class="d-flex align-items-center">

            <div class="container">
                <div class="row">
                    <div class="col-lg-12 pt-5 pt-lg-0 order-2 order-lg-1">
                        <br><br><h1>Design Of a Secure data Sharing System using Identity-Based Proxy Re-Encryption And Blockchain-Based Access Control</h1>
                    </div>
                </div>
            </div>

        </section><!-- End Hero -->

        <main id="main">

            <!-- ======= System Architecture & Workflow Section ======= -->
            <section id="architecture" class="about bg-light py-5">
                <div class="container">
                    <div class="section-title text-center mb-4">
                        <h2>System Architecture & Cryptographic Workflow</h2>
                        <p class="text-muted">Identity-Based Proxy Re-Encryption (IBE-PRE) & Ethereum Blockchain Access Control</p>
                    </div>
                    <div class="row justify-content-center mb-5">
                        <div class="col-lg-12" data-aos="fade-up">
                            <div class="card border-0 shadow-sm rounded-lg overflow-hidden text-center p-3">
                                <img src="assets/img/proxy_reencryption_flow.png" class="img-fluid w-100" alt="Proxy Re-Encryption Flow" style="width: 100%; max-height: 650px; object-fit: contain; background: #fff;">
                                <div class="card-body bg-white text-center">
                                    <h4 class="card-title font-weight-bold text-primary">Proxy Re-Encryption Cryptographic Workflow</h4>
                                    <p class="card-text text-secondary lead mb-0">Outsourced Identity-Based Encryption (IBE) & Re-Encryption Key Generation ($rk_{A \to B}$) granting decryption rights without disclosing private keys.</p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </section>

        </main><!-- End #main -->

        <!-- ======= Footer ======= -->
        <footer id="footer">
            <div class="container py-4">
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
