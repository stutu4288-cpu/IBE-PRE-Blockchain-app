#!/usr/bin/env python3
"""
Python Mail Gateway — Replicates Java Networks.Mail module.
Uses exact SMTP credentials from Java Mail.java:
- Host: smtp.gmail.com
- Port: 465 (SSL)
- User: stubtechict@gmail.com
- Pass: zgsi mnox gaue yyqv
"""

import smtplib
import sys
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

SMTP_HOST = "smtp.gmail.com"
SMTP_PORT = 465
SMTP_USER = "stubtechict@gmail.com"
SMTP_PASS = "zgsi mnox gaue yyqv"

def secret_mail(msg_body: str, name_or_subj: str, recipient_email: str) -> bool:
    """
    Replicates Java Mail.secretMail(String msg, String name, String email)
    """
    if not recipient_email or "@" not in recipient_email:
        sys.stderr.write(f"[SMTP Mailer] Invalid recipient email: {recipient_email}\n")
        return False

    subject = "Re-Encryption Key & Private Key Notification"
    if name_or_subj and name_or_subj not in ["SecretKey", "Private_Key"]:
        subject = f"Re-Encryption Notification for {name_or_subj}"

    sys.stderr.write(f"[SMTP Mailer] Sending live SMTP email to {recipient_email} via {SMTP_HOST}:{SMTP_PORT}...\n")
    try:
        msg = MIMEMultipart()
        msg['From'] = f"Proxy Re-Encryption System <{SMTP_USER}>"
        msg['To'] = recipient_email
        msg['Subject'] = subject
        
        msg.attach(MIMEText(msg_body, 'plain'))
        
        with smtplib.SMTP_SSL(SMTP_HOST, SMTP_PORT, timeout=5) as server:
            server.login(SMTP_USER, SMTP_PASS.replace(" ", ""))
            server.sendmail(SMTP_USER, recipient_email, msg.as_string())
            
        sys.stderr.write(f"[SMTP Mailer] SUCCESS: Email delivered to {recipient_email}\n")
        return True
    except Exception as ex:
        sys.stderr.write(f"[SMTP Mailer Warning] Live delivery failed (Network/Firewall): {ex}\n")
        return False
