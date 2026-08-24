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
                    <!-- Uncomment below if you prefer to use an image logo -->
                    <!-- <a href="index.html"><img src="assets/img/logo.png" alt="" class="img-fluid"></a>-->
                </div>

                <nav class="nav-menu d-none d-lg-block">
                    <ul>
                        <li><a href="index.jsp">Home</a></li>
                        <li><a style="color:#eb5d1e" href="doLogin.jsp">Data Owner</a></li>
                        <li><a href="duLogin.jsp">Data user</a></li>
                        <li><a href="taLogin.jsp">Trusted Authority</a></li>
                        <li><a href="proxyLogin.jsp">Proxy Server</a></li>
                        <li><a href="cspLogin.jsp">CSP</a></li>
                    </ul>
                </nav><!-- .nav-menu -->

            </div>
        </header><!-- End Header -->

        <main id="main" style="padding-top: 90px;">

            <!-- ======= About Section ======= -->
            <section id="contact" class="contact">
                <div class="container" data-aos="fade-up">               
                    <center><h3>Data Owner Registration</h3></center><br>

                    <% if ("Email_Exists".equals(request.getParameter("Error"))) { %>
                        <div class="alert alert-danger text-center font-weight-bold" style="font-size:15px;">
                            <i class="icofont-close-circled"></i> Registration Failed! This email address is already registered.
                        </div>
                    <% } %>
                    <% if ("Phone_Exists".equals(request.getParameter("Error"))) { %>
                        <div class="alert alert-danger text-center font-weight-bold" style="font-size:15px;">
                            <i class="icofont-close-circled"></i> Registration Failed! This phone number is already registered.
                        </div>
                    <% } %>
                    <% if ("Invalid_Email".equals(request.getParameter("Error"))) { %>
                        <div class="alert alert-warning text-center font-weight-bold" style="font-size:15px;">
                            <i class="icofont-warning"></i> Invalid email format! Please enter a valid email address.
                        </div>
                    <% } %>
                    <% if ("Invalid_Phone".equals(request.getParameter("Error"))) { %>
                        <div class="alert alert-warning text-center font-weight-bold" style="font-size:15px;">
                            <i class="icofont-warning"></i> Invalid phone number! Exactly 10 numeric digits required (e.g. 0557185634).
                        </div>
                    <% } %>
                    <% if ("Short_Password".equals(request.getParameter("Error"))) { %>
                        <div class="alert alert-warning text-center font-weight-bold" style="font-size:15px;">
                            <i class="icofont-warning"></i> Password too short! Minimum 4 characters required.
                        </div>
                    <% } %>

                    <div class="row mt-4">
                        <div class="col-lg-12">
                            <form action="doReg" method="post" id="doSignupForm" role="form" onsubmit="return validateForm();">
                                <div class="form-row">
                                    <div class="col-md-6 form-group">
                                        <label>Full Name :</label>
                                        <input type="text" class="form-control" name="username" id="username" placeholder="Enter Full Name" pattern="[A-Za-z\s]{2,50}" title="Letters and spaces only (2-50 characters)" required />
                                        <small class="form-text text-muted">Full legal name (letters only)</small>
                                    </div>
                                    <div class="col-md-6 form-group">
                                        <label>Email Address :</label>
                                        <input type="email" class="form-control" name="email" id="email" placeholder="name@example.com" required />
                                        <small class="form-text text-muted">We will send private key notifications here</small>
                                    </div>
                                </div>
                                <div class="form-row">
                                    <div class="col-md-6 form-group">
                                        <label>Date of Birth :</label>
                                        <input type="date" class="form-control" name="dob" id="dob" max="2026-08-24" required />
                                    </div>
                                    <div class="col-md-6 form-group">
                                        <label>Gender :</label>
                                        <select class="form-control" name="gender" required>
                                            <option value="">Select Your Gender</option>
                                            <option value="Male">Male</option>
                                            <option value="Female">Female</option>
                                            <option value="Others">Others</option>
                                        </select>
                                    </div>
                                </div>
                                <div class="form-row">
                                    <div class="col-md-6 form-group">
                                        <label>Phone Number :</label>
                                        <input type="tel" class="form-control" name="phone" id="phone" placeholder="10 numeric digits (e.g. 0557185634)" pattern="[0-9]{10}" maxlength="10" title="Exactly 10 numeric digits required" required oninput="this.value = this.value.replace(/[^0-9]/g, '');" />
                                        <small class="form-text text-muted">Exactly 10 digits (digits only)</small>
                                    </div>
                                    <div class="col-md-6 form-group">
                                        <label>Address :</label>
                                        <input type="text" class="form-control" name="address" id="address" placeholder="Enter Residential Address" required />
                                    </div>
                                </div>
                                <div class="form-row">
                                    <div class="col-md-6 form-group">
                                        <label>Password :</label>
                                        <div class="input-group">
                                            <input type="password" class="form-control" name="pass" id="pass" placeholder="Min 4 characters" minlength="4" required onkeyup="checkPasswordMatch();" />
                                            <div class="input-group-append">
                                                <button class="btn btn-outline-secondary" type="button" onclick="togglePass('pass');"><i class="icofont-eye" id="passEye"></i></button>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-6 form-group">
                                        <label>Confirm Password :</label>
                                        <input type="password" class="form-control" id="confirm_pass" placeholder="Re-enter Password" minlength="4" required onkeyup="checkPasswordMatch();" />
                                        <small id="passMatchMsg" class="form-text font-weight-bold"></small>
                                    </div>
                                </div>
                                <div class="form-group mt-3">
                                    <div class="text-center">
                                        <button type="submit" class="btn btn-success btn-lg px-5" id="submitBtn"><i class="icofont-check-circled"></i> Create Account</button>
                                        <a href="doLogin.jsp" class="btn btn-secondary btn-lg px-4 ml-2">Back to Login</a>
                                    </div>
                                </div>
                            </form>
                        </div>
                    </div>

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

                        function checkPasswordMatch() {
                            var p1 = document.getElementById("pass").value;
                            var p2 = document.getElementById("confirm_pass").value;
                            var msg = document.getElementById("passMatchMsg");
                            var btn = document.getElementById("submitBtn");

                            if (p2.length === 0) {
                                msg.innerHTML = "";
                                btn.disabled = false;
                                return;
                            }

                            if (p1 === p2) {
                                msg.style.color = "green";
                                msg.innerHTML = "✔ Passwords match";
                                btn.disabled = false;
                            } else {
                                msg.style.color = "red";
                                msg.innerHTML = "✖ Passwords do not match";
                                btn.disabled = true;
                            }
                        }

                        function validateForm() {
                            var p1 = document.getElementById("pass").value;
                            var p2 = document.getElementById("confirm_pass").value;
                            if (p1 !== p2) {
                                alert("Passwords do not match!");
                                return false;
                            }
                            return true;
                        }
                    </script>
                </div>
            </section><!-- End Contact Section -->
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
