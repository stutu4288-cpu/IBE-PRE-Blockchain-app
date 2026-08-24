<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="utf-8">
        <meta content="width=device-width, initial-scale=1.0" name="viewport">

        <title>Proxy Re-Encryption - Account Recovery</title>

        <!-- Favicons & Google Fonts -->
        <link href="assets/img/favicon.png" rel="icon">
        <link href="https://fonts.googleapis.com/css?family=Open+Sans:300,400,600,700|Poppins:300,400,500,600,700" rel="stylesheet">

        <!-- Vendor CSS Files -->
        <link href="assets/vendor/bootstrap/css/bootstrap.min.css" rel="stylesheet">
        <link href="assets/vendor/icofont/icofont.min.css" rel="stylesheet">
        <link href="assets/css/style.css" rel="stylesheet">
    </head>
    <body>

        <!-- ======= Header ======= -->
        <header id="header" class="fixed-top">
            <div class="container-fluid d-flex">
                <div class="logo mr-auto">
                    <h1 class="text-light"><a href="index.jsp"><span>Re-Encryption</span></a></h1>
                </div>
                <nav class="nav-menu d-none d-lg-block">
                    <ul>
                        <li><a href="index.jsp">Home</a></li>
                        <li><a href="doLogin.jsp">Data Owner</a></li>
                        <li><a href="duLogin.jsp">Data User</a></li>
                        <li><a href="taLogin.jsp">Trusted Authority</a></li>
                    </ul>
                </nav>
            </div>
        </header>

        <main id="main" style="padding-top: 100px;">
            <section id="contact" class="contact">
                <div class="container" data-aos="fade-up">
                    <center>
                        <h3>Account & Credential Recovery</h3>
                        <p class="text-muted" style="font-size: 15px;">
                            <i class="icofont-info-circle" style="color: #eb5d1e;"></i> 
                            Enter your registered email address to recover your Password and assigned Identity Private Key.
                        </p>
                    </center><br>

                    <% if (request.getParameter("Sent") != null) { 
                           String tempPass = (String) session.getAttribute("tempPass");
                           String tempPkey = (String) session.getAttribute("tempPkey");
                     %>
                         <div class="alert alert-success text-center font-weight-bold" style="font-size: 16px;">
                             <i class="icofont-check-circled"></i> Password Reset & Private Key Recovered Successfully!<br>
                             <% if (tempPass != null && !tempPass.isEmpty()) { %>
                                 <div class="mt-2 text-left bg-light p-3 rounded text-dark font-weight-normal style="font-size: 14px;">
                                     <strong>New Temporary Password:</strong> <code style="font-size: 16px; color: #eb5d1e;"><%= tempPass %></code><br>
                                     <strong>Identity Private Key:</strong> <code style="font-size: 15px; color: #007bff;"><%= tempPkey != null ? tempPkey : "" %></code><br>
                                     <small class="text-muted"><i class="icofont-info-circle"></i> A copy has also been sent to your email address.</small>
                                 </div>
                             <% } %>
                         </div>
                     <% } %>
                    <% if (request.getParameter("NotFound") != null) { %>
                        <div class="alert alert-danger text-center font-weight-bold" style="font-size: 16px;">
                            <i class="icofont-warning"></i> No approved account found for the specified email address.
                        </div>
                    <% } %>

                    <div class="row justify-content-center">
                        <div class="col-lg-6">
                            <form action="recoverCredentials.jsp" method="post" class="shadow p-4 rounded bg-white">
                                <div class="form-group">
                                    <label class="font-weight-bold">Select Account Role :</label>
                                    <select class="form-control" name="role" required>
                                        <option value="owner">Data Owner</option>
                                        <option value="user">Data User</option>
                                    </select>
                                </div>
                                <div class="form-group">
                                    <label class="font-weight-bold">Registered Email Address :</label>
                                    <input type="email" class="form-control" name="email" placeholder="Enter your registered email address" required />
                                </div>
                                <div class="form-group text-center mt-4">
                                    <button type="submit" class="btn btn-primary btn-lg btn-block">
                                        <i class="icofont-envelope"></i> Recover Password & Private Key
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </section>
        </main>

        <footer id="footer">
            <div class="container py-4 text-center">
                &copy; <strong><span>2026</span></strong> Secure Data Sharing System.
            </div>
        </footer>

        <script src="assets/vendor/jquery/jquery.min.js"></script>
        <script src="assets/vendor/bootstrap/js/bootstrap.bundle.min.js"></script>
    </body>
</html>
