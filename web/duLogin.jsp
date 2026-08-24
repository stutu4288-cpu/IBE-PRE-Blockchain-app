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
    <body>
        <!-- ======= Header ======= -->
        <header id="header" class="fixed-top">
            <div class="container-fluid d-flex">

                <div class="logo mr-auto">
                    <h1 class="text-light"><a><span>Re-Encryption</span></a></h1>
                </div>

                <nav class="nav-menu d-none d-lg-block">
                    <ul>
                        <li><a href="index.jsp">Home</a></li>
                        <li><a href="doLogin.jsp">Data Owner</a></li>
                        <li><a style="color:#eb5d1e" href="duLogin.jsp">Data user</a></li>
                        <li><a href="taLogin.jsp">Trusted Authority</a></li>
                        <li><a href="proxyLogin.jsp">Proxy Server</a></li>
                        <li><a href="cspLogin.jsp">CSP</a></li>
                    </ul>
                </nav><!-- .nav-menu -->

            </div>
        </header><!-- End Header -->

        <main id="main" style="padding-top: 90px;">

            <!-- ======= Contact Section ======= -->
            <section id="contact" class="contact">
                <div class="container" data-aos="fade-up">

                    <% if (request.getParameter("Register_Success") != null) { %>
                        <div class="alert alert-success alert-dismissible fade show text-center py-3 shadow-sm mb-4" role="alert" style="border-left: 5px solid #198754; background-color: #f8fff9;">
                            <h5 class="alert-heading text-success font-weight-bold mb-1">
                                <i class="icofont-check-circled" style="font-size: 24px;"></i> Registration Successful!
                            </h5>
                            <p class="mb-0 text-dark" style="font-size: 15px;">
                                Your Data User account has been created. It is currently <b>Pending Approval</b> by the Trusted Authority. Once approved, you can log in below.
                            </p>
                            <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                                <span aria-hidden="true">&times;</span>
                            </button>
                        </div>
                    <% } %>

                    <% if (request.getParameter("Failed") != null) { %>
                        <div class="alert alert-danger alert-dismissible fade show text-center py-3 shadow-sm mb-4" role="alert" style="border-left: 5px solid #dc3545;">
                            <h5 class="alert-heading text-danger font-weight-bold mb-1">
                                <i class="icofont-close-circled" style="font-size: 24px;"></i> Authentication Failed
                            </h5>
                            <p class="mb-0 text-dark" style="font-size: 14px;">
                                Invalid login credentials or private key. Please verify your Email/Phone/Username, Private Key, and Password.
                            </p>
                            <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                                <span aria-hidden="true">&times;</span>
                            </button>
                        </div>
                    <% } %>

                    <% if ("Account_Pending".equals(request.getParameter("msg"))) { %>
                        <div class="alert alert-warning alert-dismissible fade show text-center py-3 shadow-sm mb-4" role="alert" style="border-left: 5px solid #ffc107;">
                            <h5 class="alert-heading text-warning font-weight-bold mb-1">
                                <i class="icofont-clock-time" style="font-size: 24px;"></i> Account Pending Approval
                            </h5>
                            <p class="mb-0 text-dark" style="font-size: 14px;">
                                The Trusted Authority has not yet approved your Data User account. Please contact TA administrator for activation.
                            </p>
                            <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                                <span aria-hidden="true">&times;</span>
                            </button>
                        </div>
                    <% } %>

                    <% if ("Account_Revoked".equals(request.getParameter("msg"))) { %>
                        <div class="alert alert-danger alert-dismissible fade show text-center py-3 shadow-sm mb-4" role="alert" style="border-left: 5px solid #dc3545;">
                            <h5 class="alert-heading text-danger font-weight-bold mb-1">
                                <i class="icofont-ban" style="font-size: 24px;"></i> Access Revoked
                            </h5>
                            <p class="mb-0 text-dark" style="font-size: 14px;">
                                Your account access has been revoked by the Trusted Authority.
                            </p>
                            <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                                <span aria-hidden="true">&times;</span>
                            </button>
                        </div>
                    <% } %>

                    <% if (request.getParameter("Locked") != null) { %>
                        <div class="alert alert-danger alert-dismissible fade show text-center py-3 shadow-sm mb-4" role="alert" style="border-left: 5px solid #dc3545;">
                            <h5 class="alert-heading text-danger font-weight-bold mb-1">
                                <i class="icofont-lock" style="font-size: 24px;"></i> Account Temporarily Locked
                            </h5>
                            <p class="mb-0 text-dark" style="font-size: 14px;">
                                5 consecutive failed login attempts detected. For security, login is locked for 10 minutes.
                            </p>
                            <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                                <span aria-hidden="true">&times;</span>
                            </button>
                        </div>
                    <% } %>

                    <div class="row mt-3 align-items-center">
                        <div class="col-lg-6 mb-4 mb-lg-0">
                            <img src="assets/img/dulogin.jpg" class="img-fluid rounded shadow-sm w-100" style="max-height: 420px; object-fit: cover;" alt="Data User Login" onerror="this.src='assets/img/login.jpg';" />
                        </div>
                        <div class="col-lg-6">
                            <form action="duSignin.jsp" method="post" role="form" id="duLoginForm" onsubmit="return validateLoginForm();">
                                <div class="form-group">
                                    <label class="font-weight-bold">Email / Phone / Username :</label>
                                    <input type="text" class="form-control" name="email" id="loginId" placeholder="Enter Email, 10-digit Phone, or Username" required />
                                    <small class="form-text text-muted">e.g. abdul, 0557185634, or name@gmail.com</small>
                                </div>
                                <div class="form-group">
                                    <label class="font-weight-bold">Private Key (Optional) :</label>
                                    <input type="text" class="form-control" name="pkey" id="pkey" placeholder="Base64 Private Key (e.g. +DjLGVNxIYA=)" />
                                    <small class="form-text text-muted">Leave empty if logging in with Password</small>
                                </div>
                                <div class="form-group">
                                    <label class="font-weight-bold">Password :</label>
                                    <div class="input-group">
                                        <input type="password" class="form-control" name="pass" id="pass" placeholder="Enter Account Password" required />
                                        <div class="input-group-append">
                                            <button class="btn btn-outline-secondary" type="button" onclick="togglePass('pass');"><i class="icofont-eye" id="passEye"></i></button>
                                        </div>
                                    </div>
                                </div>
                                <div class="form-group mt-4">
                                    <button type="submit" class="btn btn-success btn-lg px-5 shadow-sm"><i class="icofont-sign-in"></i> Login</button>
                                    <hr>
                                    <p class="mb-1">Don't have an account? <a href="duSignup.jsp" class="font-weight-bold text-primary">Register Here</a></p>
                                    <p><a href="forgotPassword.jsp" style="color:#eb5d1e; font-weight:bold;"><i class="icofont-key"></i> Forgot Password or Private Key?</a></p>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </section><!-- End Contact Section -->
        </main><!-- End #main -->

        <script>
            function togglePass(id) {
                var input = document.getElementById(id);
                var eye = document.getElementById(id + "Eye");
                if (input.type === "password") {
                    input.type = "text";
                    eye.className = "icofont-eye-blocked";
                } else {
                    input.type = "password";
                    eye.className = "icofont-eye";
                }
            }

            function validateLoginForm() {
                var id = document.getElementById("loginId").value.trim();
                var pass = document.getElementById("pass").value;

                if (id.length === 0) {
                    alert("Please enter your Email, Phone Number, or Username.");
                    return false;
                }
                if (pass.length === 0) {
                    alert("Please enter your Password.");
                    return false;
                }
                return true;
            }
        </script>

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
