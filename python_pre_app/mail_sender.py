#!/usr/bin/env python3
"""
Python Mail Gateway — Replicates Java Networks.Mail module with Dual-Mode SSL/TLS.
Uses Gmail SMTP credentials:
- Host: smtp.gmail.com
- Ports: 465 (SSL) / 587 (STARTTLS)
- User: stubtechict@gmail.com
- Pass: zgsi mnox gaue yyqv
"""

import os
import smtplib
import sys
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

SMTP_HOST = os.environ.get("SMTP_HOST", "smtp.gmail.com")
SMTP_USER = os.environ.get("SMTP_USER", "stubtechict@gmail.com")
SMTP_PASS = os.environ.get("SMTP_PASS", "zgsi mnox gaue yyqv").replace(" ", "")

def secret_mail(msg_body: str, name_or_subj: str, recipient_email: str) -> bool:
    """
    Sends live SMTP email to recipient_email via Gmail SSL (Port 465) or STARTTLS (Port 587).
    """
    if not recipient_email or "@" not in recipient_email:
        sys.stderr.write(f"[SMTP Mailer] Invalid recipient email: {recipient_email}\n")
        return False

    subject = "Proxy Re-Encryption Platform Notification"
    if name_or_subj:
        if name_or_subj in ["Registration", "Pending"]:
            subject = "Registration Request Received - Pending TA Approval"
        elif name_or_subj in ["Approved", "Private_Key", "SecretKey"]:
            subject = "Account Approved - Your Cryptographic Private Key"
        else:
            subject = f"Proxy Re-Encryption Notification: {name_or_subj}"

    sys.stderr.write(f"[SMTP Mailer] Dispatching email to {recipient_email} (Subject: {subject})...\n")
    
    msg = MIMEMultipart()
    msg['From'] = f"Proxy Re-Encryption Platform <{SMTP_USER}>"
    msg['To'] = recipient_email
    msg['Subject'] = subject
    msg.attach(MIMEText(msg_body, 'plain'))

    # Method 1: Try SSL on port 465
    try:
        with smtplib.SMTP_SSL(SMTP_HOST, 465, timeout=10) as server:
            server.login(SMTP_USER, SMTP_PASS)
            server.sendmail(SMTP_USER, recipient_email, msg.as_string())
        sys.stderr.write(f"[SMTP Mailer] SUCCESS (SSL 465): Delivered to {recipient_email}\n")
        return True
    except Exception as ex1:
        sys.stderr.write(f"[SMTP Mailer Note] SSL 465 attempt ({ex1}). Retrying with STARTTLS 587...\n")
        # Method 2: Try STARTTLS on port 587
        try:
            with smtplib.SMTP(SMTP_HOST, 587, timeout=10) as server:
                server.starttls()
                server.login(SMTP_USER, SMTP_PASS)
                server.sendmail(SMTP_USER, recipient_email, msg.as_string())
            sys.stderr.write(f"[SMTP Mailer] SUCCESS (STARTTLS 587): Delivered to {recipient_email}\n")
            return True
        except Exception as ex2:
            sys.stderr.write(f"[SMTP Mailer Error] Live delivery failed on both 465 & 587: {ex2}\n")
            return False

def send_registration_pending_email(recipient_email: str, recipient_name: str, role_name: str) -> bool:
    """
    Sends confirmation email immediately upon registration.
    """
    body = (
        f"Hello {recipient_name},\n\n"
        f"Thank you for registering on the Proxy Re-Encryption Platform as a {role_name}!\n\n"
        f"Account Details:\n"
        f"- Email: {recipient_email}\n"
        f"- Role: {role_name}\n"
        f"- Status: PENDING APPROVAL\n\n"
        f"Your registration request has been submitted to the Trusted Authority (TA).\n"
        f"As soon as the TA approves your account, you will receive a follow-up email containing your "
        f"unique Base64 Cryptographic Private Key required for login.\n\n"
        f"Best regards,\n"
        f"Proxy Re-Encryption System Administrator"
    )
    return secret_mail(body, "Registration", recipient_email)
