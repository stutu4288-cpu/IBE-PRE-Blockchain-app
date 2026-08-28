import smtplib
import socket
import ssl
import sys
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

SMTP_HOST = "smtp.gmail.com"
SMTP_USER = "stubtechict@gmail.com"
SMTP_PASS = "zgsmnoxgaueyyqv"

def test_send():
    recipient = "princentiamoah3476@gmail.com"
    msg = MIMEMultipart()
    msg['From'] = f"Proxy Re-Encryption Platform <{SMTP_USER}>"
    msg['To'] = recipient
    msg['Subject'] = "Test IPv4 SMTP Mailer"
    msg.attach(MIMEText("Testing live IPv4 SMTP email delivery.", 'plain'))

    # Resolve IPv4 addresses
    ipv4_list = []
    try:
        infos = socket.getaddrinfo(SMTP_HOST, 587, socket.AF_INET, socket.SOCK_STREAM)
        ipv4_list = list(set([info[4][0] for info in infos if info[4]]))
        print("Resolved IPv4 addresses for smtp.gmail.com:", ipv4_list)
    except Exception as e:
        print("DNS resolution failed:", e)

    # Try 587 STARTTLS with IPv4
    for ip in ipv4_list:
        try:
            print(f"Trying STARTTLS 587 to IPv4 {ip}...")
            context = ssl.create_default_context()
            with smtplib.SMTP(ip, 587, timeout=10) as server:
                server.ehlo(SMTP_HOST)
                server.starttls(context=context)
                server.ehlo(SMTP_HOST)
                server.login(SMTP_USER, "zgsi mnox gaue yyqv".replace(" ", ""))
                server.sendmail(SMTP_USER, recipient, msg.as_string())
            print("SUCCESS via 587 IPv4!")
            return True
        except Exception as ex:
            print(f"Failed on {ip}:587 - {ex}")

    # Try 465 SSL with IPv4
    for ip in ipv4_list:
        try:
            print(f"Trying SSL 465 to IPv4 {ip}...")
            context = ssl.create_default_context()
            with smtplib.SMTP_SSL(ip, 465, timeout=10, context=context) as server:
                server.login(SMTP_USER, "zgsi mnox gaue yyqv".replace(" ", ""))
                server.sendmail(SMTP_USER, recipient, msg.as_string())
            print("SUCCESS via 465 IPv4!")
            return True
        except Exception as ex:
            print(f"Failed on {ip}:465 - {ex}")

    return False

if __name__ == "__main__":
    test_send()
