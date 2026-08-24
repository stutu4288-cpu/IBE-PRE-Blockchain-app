/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package DBconnection;

/**
 *
 * @author JAVA-JP
 */
import java.sql.Connection;
import java.sql.DriverManager;

public class SQLconnection {
    
static Connection con;

    
    /**
     *
     * @return
     */
    public static Connection getconnection() {
        Connection con = null;
        try {
            Class.forName("com.mysql.jdbc.Driver");

            // 1. Check Railway / Cloud Environment Variables
            String host = System.getenv("MYSQLHOST");
            if (host == null || host.isEmpty()) host = System.getenv("MYSQL_HOST");

            String port = System.getenv("MYSQLPORT");
            if (port == null || port.isEmpty()) port = System.getenv("MYSQL_PORT");
            if (port == null || port.isEmpty()) port = "3306";

            String db = System.getenv("MYSQLDATABASE");
            if (db == null || db.isEmpty()) db = System.getenv("MYSQL_DATABASE");
            if (db == null || db.isEmpty()) db = "prea";

            String user = System.getenv("MYSQLUSER");
            if (user == null || user.isEmpty()) user = System.getenv("MYSQL_USER");

            String pass = System.getenv("MYSQLPASSWORD");
            if (pass == null || pass.isEmpty()) pass = System.getenv("MYSQL_PASSWORD");

            if (host != null && !host.isEmpty() && user != null && !user.isEmpty()) {
                String cloudUrl = "jdbc:mysql://" + host + ":" + port + "/" + db + "?useSSL=false&allowPublicKeyRetrieval=true&autoReconnect=true";
                try {
                    con = DriverManager.getConnection(cloudUrl, user, pass != null ? pass : "");
                    if (con != null) return con;
                } catch (Exception exCloud) {
                    System.err.println("Cloud DB connection failed, attempting local fallback: " + exCloud.getMessage());
                }
            }

            // 2. Local Fallback (XAMPP / Local MySQL)
            try {
                con = DriverManager.getConnection("jdbc:mysql://localhost:3306/prea", "root", "");
            } catch (Exception e1) {
                con = DriverManager.getConnection("jdbc:mysql://localhost:3306/prea", "root", "root");
            }
        } catch (Exception e) {
            System.err.println("SQLconnection Error: " + e.getMessage());
            e.printStackTrace();
        }
        return con;
    }
}

