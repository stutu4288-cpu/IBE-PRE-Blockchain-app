<%-- 
    Document   : index
    Created on : 26 Aug, 2024, 4:51:26 PM
    Author     : JAVA-JP
--%>

<%@page import="java.io.FileWriter"%>
<%@page import="java.util.Base64"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%><%@page import="java.io.File"%>
<%@page import="com.oreilly.servlet.MultipartRequest"%>
<%@page import="javax.crypto.KeyGenerator"%>
<%@page import="javax.crypto.SecretKey"%>
<%@page import="Action.Encryption"%>
<%@page import="java.io.FileReader"%>
<%@page import="java.io.BufferedReader"%>
<%@page import="Action.SplitFile"%>
<%@page import="java.security.SecureRandom"%>
<%@page import="java.util.Random"%>
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
<%

    String filepath = System.getProperty("java.io.tmpdir");
    if (filepath == null || filepath.isEmpty()) {
        filepath = "C:/xampp/tomcat/temp/";
    }
    File testDir = new File(filepath);
    if (!testDir.exists()) {
        testDir.mkdirs();
    }
    String f1, f2, f3;

    try {
        MultipartRequest m = new MultipartRequest(request, filepath, 100 * 1024 * 1024);
        String filekeyword = m.getParameter("keyword");
        File file = m.getFile("fileToUpload");
        if (file == null) {
            java.util.Enumeration files = m.getFileNames();
            if (files != null && files.hasMoreElements()) {
                String fNameKey = (String) files.nextElement();
                file = m.getFile(fNameKey);
            }
        }
        if (file == null || !file.exists()) {
            response.sendRedirect("uploadFile.jsp?msg=Upload_File_Not_Found");
            return;
        }
        String filename = file.getName();
        session.setAttribute("filename", filename);
        session.setAttribute("filepath", filepath);

        Connection con = SQLconnection.getconnection();
        Statement st = con.createStatement();

        ResultSet rs = st.executeQuery("Select * from do_files where filekeyword ='" + filekeyword + "'");
        if (rs.next()) {

            response.sendRedirect("uploadFile.jsp?msg=FileKeyword_Already_Exists");
            return;
        }

        byte[] fileBytes = java.nio.file.Files.readAllBytes(file.toPath());
        String origHash = CryptoUtils.sha256(fileBytes);
        session.setAttribute("origHash", origHash);
        session.setAttribute("fileBytes", fileBytes);

        String rawBase64Content = Base64.getEncoder().encodeToString(fileBytes);
        session.setAttribute("filecontent", rawBase64Content);

        KeyGenerator Attrib_key = KeyGenerator.getInstance("AES");
        Attrib_key.init(128);
        SecretKey secretKey = Attrib_key.generateKey();
        session.setAttribute("secretKey", secretKey);

        long aTime = System.currentTimeMillis();
        Encryption e = new Encryption();
        byte[] encBytes = e.encryptGCM(fileBytes, secretKey);
        String encryptedtext = Base64.getEncoder().encodeToString(encBytes);
        session.setAttribute("cipherBytes", encBytes);
        session.setAttribute("EncryptText", encryptedtext);

        byte[] b = secretKey.getEncoded();
        String Dkey = Base64.getEncoder().encodeToString(b);
        session.setAttribute("Dkey", Dkey);

        KeyGenerator Attrib_key1 = KeyGenerator.getInstance("AES");
        Attrib_key1.init(128);
        SecretKey secretKey1 = Attrib_key1.generateKey();

        Encryption e1 = new Encryption();
        byte[] encBytes1 = e1.encryptGCM(fileBytes, secretKey1);
        String encryptedtxt1 = Base64.getEncoder().encodeToString(encBytes1);
        session.setAttribute("EncryptText1", encryptedtxt1);
        long bTime = System.currentTimeMillis();
        float encryptTime = (float)(bTime - aTime);
        session.setAttribute("encryptTime", encryptTime);

        byte[] b1 = secretKey1.getEncoded();
        String RDkey = Base64.getEncoder().encodeToString(b1);
        session.setAttribute("RDkey", RDkey);

        // Split ciphertext string into 3 equal blocks for distributed verification
        int totalLen = encryptedtext.length();
        int partLen = totalLen / 3;
        String b1Str = encryptedtext.substring(0, partLen);
        String b2Str = encryptedtext.substring(partLen, partLen * 2);
        String b3Str = encryptedtext.substring(partLen * 2);

        session.setAttribute("ori_block1", b1Str);
        session.setAttribute("ori_block2", b2Str);
        session.setAttribute("ori_block3", b3Str);

        String encryptedtext1 = e.encrypt(b1Str, secretKey);
        String encryptedtext2 = e.encrypt(b2Str, secretKey);
        String encryptedtext3 = e.encrypt(b3Str, secretKey);

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
                        <li><a style="color:#eb5d1e" href="uploadFile.jsp">Upload File</a></li>
                        <li><a href="myFiles.jsp">My Files</a></li>
                        <li><a href="requestedFiles.jsp">Requested Files</a></li>
                        <li><a href="index.jsp">Logout</a></li>
                    </ul>
                </nav><!-- .nav-menu -->

            </div>
        </header><!-- End Header --><main id="main" style="margin-top: 100px;">

            <!-- ======= About Section ======= -->
            <section id="contact" class="contact">
                <div class="container" data-aos="fade-up">
                    <center><h3>Upload File</h3></center><br>
                    <div class="row mt-5">
                        <div class="col-md-2">
                        </div>
                        <div class="col-md-9">
                            <form action="DataUpload" method="post" role="form" enctype="multipart/form-data">
                                <div class="form-group">
                                    <input type="hidden" name="keyword" value="<%=filekeyword%>" readonly="">
                                    <input type="hidden" name="doid" value="<%=session.getAttribute("doid") != null ? session.getAttribute("doid") : ""%>">
                                    <input type="hidden" name="doname" value="<%=session.getAttribute("doname") != null ? session.getAttribute("doname") : ""%>">
                                    <input type="hidden" name="domail" value="<%=session.getAttribute("domail") != null ? session.getAttribute("domail") : ""%>">
                                    <label>File Name :</label>
                                    <input type="text" class="form-control" name="filename" value="<%=filename%>" readonly=""><br>
                                    <label>Block 1 :</label>
                                    <textarea name="block1" readonly="" class="form-control" style="height: 120px; resize: none;"><%=encryptedtext1%></textarea><br>
                                    <label>Block 2 :</label>
                                    <textarea name="block2" readonly="" class="form-control"style="height: 120px; resize: none;"><%=encryptedtext2%></textarea><br>
                                    <label>Block 3 :</label>
                                    <textarea name="block3" readonly="" class="form-control"style="height: 120px; resize: none;"><%=encryptedtext3%></textarea><br>
                                </div>
                                <div class="form-group">
                                    <button type="submit" class="btn btn-success btn-lg">Upload</button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </section><!-- End About Section -->
            <%   } catch (Exception e) {
                    e.printStackTrace();
                }
            %>
        </main><!-- End #main -->

        <!-- ======= Footer ======= -->
        <footer id="footer">
            <div class="container py-4">
                <center>&copy;  <strong><span>2024</span></strong>.</center>
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
