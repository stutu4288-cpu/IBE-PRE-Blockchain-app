<%-- 
    Document   : access_grant
    Created on : sept 30 , 2020, 5:14:44 AM
    Author     : Lenovo
--%>

<%@page import="Networks.Mail"%>
<%@page import="DBconnection.SQLconnection"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.ResultSet"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // Session Access Guard
    if (session.getAttribute("proxy_user") == null) {
        response.sendRedirect("proxyLogin.jsp?Auth_Required");
        return;
    }
%>
<%
    String fid = request.getParameter("fid");
    String mail = request.getParameter("mail");

    Connection con = null;
    Statement st = null;
    Statement st1 = null;
    Connection conn = SQLconnection.getconnection();
    Statement sto = conn.createStatement();
    st = conn.createStatement();

    try {
        java.text.SimpleDateFormat sdfGrant = new java.text.SimpleDateFormat("yyyy/MM/dd HH:mm:ss");
        String grantedTime = sdfGrant.format(new java.util.Date());

        int i = sto.executeUpdate("update request set status='Approved', granted_time='" + grantedTime + "' where fid='" + fid + "' ");
        if (i != 0) {
            ResultSet rs = st.executeQuery(" SELECT r.filename, r.rdkey FROM request r WHERE r.fid = '" + fid + "' ");
            if (rs.next()) {
                String fname = rs.getString("filename");
                String rdkey = rs.getString("rdkey");
                
                // Ethereum Blockchain Grant Access Logging via Ganache
                String txHash = Networks.EthereumBridge.grantAccessOnChain(fid, mail, rdkey);
                sto.executeUpdate("update request set tx_hash='" + txHash + "' where fid='" + fid + "' ");

                String msggg = "Filename : " + fname + "\nRe-Decryption key: " + rdkey + "\nEthereum TxHash: " + txHash + "\nGranted Time: " + grantedTime;
                Mail ma = new Mail();
                ma.secretMail(msggg, "SecretKey", mail);
                response.sendRedirect("fileRequest.jsp?Approved");
            } else {
                response.sendRedirect("fileRequest.jsp?Failed");
            }
        }
    } catch (Exception ex) {
        ex.printStackTrace();
    }
%>
