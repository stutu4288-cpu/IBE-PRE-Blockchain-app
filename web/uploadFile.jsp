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
    <script type="text/javascript">
        function loadFile(o)
        {
            if (!o.files || !o.files[0]) return;
            var f = o.files[0];
            if (f.type.startsWith("text/") || f.name.endsWith(".txt") || f.name.endsWith(".json") || f.name.endsWith(".csv") || f.name.endsWith(".xml")) {
                var fr = new FileReader();
                fr.onload = function (e) {
                    document.getElementById("data").innerText = e.target.result;
                };
                fr.readAsText(f);
            } else {
                document.getElementById("data").innerText = "Binary / Media File Loaded:\n" + f.name + "\nSize: " + (f.size / 1024).toFixed(2) + " KB\nType: " + (f.type || "Binary document/media");
            }
        }
    </script>
    <body>

        <!-- ======= Header ======= -->
        <header id="header" class="fixed-top">
            <div class="container-fluid d-flex">

                <div class="logo mr-auto">
                    <h1 class="text-light"><a><span>Re-Encryption</span></a></h1>
                </div>

                <nav class="nav-menu d-none d-lg-block">
                    <ul>
                        <li><a href="doHome.jsp">Home</a></li>
                        <li><a style="color:#eb5d1e" href="uploadFile.jsp">Upload File</a></li>
                        <li><a href="myFiles.jsp">My Files</a></li>
                        <li><a href="requestedFiles.jsp">Requested Files</a></li>
                        <li><a href="logout.jsp">Logout</a></li>
                    </ul>
                </nav><!-- .nav-menu -->

            </div>
        </header><!-- End Header --><main id="main" style="margin-top: 100px;">

            <!-- ======= About Section ======= -->
            <section id="contact" class="contact">
                <div class="container" data-aos="fade-up">
                    <center>
                        <h3>Upload File</h3>
                        <p class="text-muted" style="font-size: 15px;">
                            Upload any file format (PDF, DOCX, Images, Video, Audio, Archives, Code, or Text). The system encrypts the binary payload with AES-256-GCM, splits ciphertext into 3 verifiable blocks, and records the transaction receipt on the Ethereum blockchain.
                        </p>
                    </center>

                    <% if (request.getParameter("File_uploaded") != null) { %>
                        <div class="alert alert-success text-center font-weight-bold" style="font-size: 16px; margin: 20px 0;">
                            <i class="icofont-check-circled"></i> File Uploaded Successfully to Cloud & Logged on Ethereum Blockchain!
                        </div>
                    <% } %>
                    <% if (request.getParameter("msg") != null && request.getParameter("msg").contains("FileKeyword_Already_Exists")) { %>
                        <div class="alert alert-danger text-center font-weight-bold" style="font-size: 16px; margin: 20px 0;">
                            <i class="icofont-warning"></i> File Keyword Already Exists! Please use a unique file keyword to prevent duplicate uploads.
                        </div>
                    <% } %>
                    <div class="row mt-5">
                        <div class="col-md-6">
                            <img src="assets/img/upload.png" width="400" height="370" />
                        </div>
                        <div class="col-md-6">
                            <form action="uploadFile1.jsp" method="post" role="form" enctype="multipart/form-data">
                                <div class="form-group">
                                    <label>File Keyword :</label>
                                    <input type="text" class="form-control" name="keyword" placeholder="Enter File Keyword" required="" />
                                </div>
                                <div class="form-group">
                                    <label><b>Select File (All Formats Supported) :</b></label>
                                    <input type="file" name="fileToUpload" onchange="loadFile(this)" class="form-control" required />
                                </div>
                                <div class="form-group">
                                    <label>Preview File :</label><br>
                                    <textarea readonly="" class="form-control" pre id="data" style="height:120px; resize: none"></textarea>
                                </div>
                                <div class="form-group">
                                    <button type="submit" class="btn btn-success btn-lg">Upload</button>
                                </div>
                            </form>
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
