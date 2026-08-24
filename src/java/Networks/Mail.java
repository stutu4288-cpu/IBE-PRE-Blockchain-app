/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package Networks;

/**
 *
 * @author Lenovo
 */
import java.util.Properties;
import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.PasswordAuthentication;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;

public class Mail {
    
public static boolean secretMail(String msg, String name, String email) {
        Properties props = new Properties();
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "465");
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.socketFactory.port", "465");
        props.put("mail.smtp.socketFactory.class", "javax.net.ssl.SSLSocketFactory");
        props.put("mail.smtp.ssl.protocols", "TLSv1.2");
        props.put("mail.smtp.ssl.trust", "smtp.gmail.com");
        props.put("mail.smtp.connectiontimeout", "3000");
        props.put("mail.smtp.timeout", "3000");

        Session session = Session.getInstance(props,
                new javax.mail.Authenticator() {
                    @Override
                    protected PasswordAuthentication getPasswordAuthentication() {
                        return new PasswordAuthentication("stubtechict@gmail.com", "zgsi mnox gaue yyqv");
                    }
                });

        System.out.println("Sending email notification to " + email);
        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress("stubtechict@gmail.com"));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(email));
            message.setSubject("Re-Encryption Key & Private Key Notification");
            message.setText(msg);

            Transport.send(message);
            System.out.println("Email sent successfully to " + email);
            return true;

        } catch (Exception e) {
            System.err.println("Live SMTP delivery warning (Firewall/Network): " + e.getMessage());
            return false;
        }
    }
}