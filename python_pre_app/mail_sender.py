#!/usr/bin/env python3
"""
Python Mail Gateway — Replicates Java Networks.Mail module.
Supports Resend / Brevo / SendGrid HTTPS API over Port 443 + Dual-Mode SMTP (465/587) with Non-Blocking Async Threading.
"""

import os
import sys
import json
import socket
import smtplib
import threading
import urllib.request
import urllib.parse
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

SMTP_HOST = os.environ.get("SMTP_HOST", "smtp.gmail.com")
SMTP_USER = os.environ.get("SMTP_USER", "stubtechict@gmail.com")
SMTP_PASS = os.environ.get("SMTP_PASS", "zgsi mnox gaue yyqv").replace(" ", "")

# Environment Variable HTTP Email API Keys (Set on Railway / Cloud dashboard)
RESEND_API_KEY = os.environ.get("RESEND_API_KEY", "")
BREVO_API_KEY = os.environ.get("BREVO_API_KEY", "")
SENDGRID_API_KEY = os.environ.get("SENDGRID_API_KEY", "")

def _send_via_http_api(subject: str, msg_body: str, recipient_email: str) -> bool:
    """
    Delivers email over HTTPS (Port 443) using Resend / Brevo / SendGrid APIs.
    Bypasses cloud provider raw SMTP port blocks.
    """
    # 1. Resend API
    if RESEND_API_KEY:
        try:
            url = "https://api.resend.com/emails"
            headers = {
                "Authorization": f"Bearer {RESEND_API_KEY.strip()}",
                "Content-Type": "application/json",
                "User-Agent": "Resend-Python-App/1.0"
            }
            payload = json.dumps({
                "from": "Proxy Re-Encryption <onboarding@resend.dev>",
                "to": [recipient_email],
                "subject": subject,
                "text": msg_body
            }).encode('utf-8')
            req = urllib.request.Request(url, data=payload, headers=headers, method="POST")
            with urllib.request.urlopen(req, timeout=10) as resp:
                if resp.status in [200, 201, 202]:
                    resp_data = resp.read().decode('utf-8')
                    sys.stderr.write(f"[Resend API Mailer] SUCCESS: Email delivered to {recipient_email} ({resp_data})\n")
                    return True
        except Exception as ex:
            err_msg = str(ex)
            if hasattr(ex, 'read'):
                try:
                    err_msg += " - " + ex.read().decode('utf-8')
                except Exception:
                    pass
            sys.stderr.write(f"[Resend API Warning] {err_msg}\n")

    # 2. Brevo API (v3)
    if BREVO_API_KEY:
        try:
            url = "https://api.brevo.com/v3/smtp/email"
            headers = {
                "api-key": BREVO_API_KEY,
                "Content-Type": "application/json",
                "Accept": "application/json"
            }
            payload = json.dumps({
                "sender": {"name": "Proxy Re-Encryption System", "email": SMTP_USER},
                "to": [{"email": recipient_email}],
                "subject": subject,
                "textContent": msg_body
            }).encode('utf-8')
            req = urllib.request.Request(url, data=payload, headers=headers, method="POST")
            with urllib.request.urlopen(req, timeout=10) as resp:
                if resp.status in [200, 201, 202]:
                    sys.stderr.write(f"[HTTP Mailer] SUCCESS (Brevo API): Delivered to {recipient_email}\n")
                    return True
        except Exception as ex:
            sys.stderr.write(f"[HTTP Mailer Warning] Brevo API error: {ex}\n")

    # 3. SendGrid API
    if SENDGRID_API_KEY:
        try:
            url = "https://api.sendgrid.com/v3/mail/send"
            headers = {
                "Authorization": f"Bearer {SENDGRID_API_KEY}",
                "Content-Type": "application/json"
            }
            payload = json.dumps({
                "personalizations": [{"to": [{"email": recipient_email}]}],
                "from": {"email": SMTP_USER, "name": "Proxy Re-Encryption System"},
                "subject": subject,
                "content": [{"type": "text/plain", "value": msg_body}]
            }).encode('utf-8')
            req = urllib.request.Request(url, data=payload, headers=headers, method="POST")
            with urllib.request.urlopen(req, timeout=10) as resp:
                if resp.status in [200, 201, 202]:
                    sys.stderr.write(f"[HTTP Mailer] SUCCESS (SendGrid API): Delivered to {recipient_email}\n")
                    return True
        except Exception as ex:
            sys.stderr.write(f"[HTTP Mailer Warning] SendGrid API error: {ex}\n")

    return False

def _deliver_email_worker(msg_body: str, name_or_subj: str, recipient_email: str):
    """
    Background worker thread function for non-blocking email dispatch.
    """
    if not recipient_email or "@" not in recipient_email:
        sys.stderr.write(f"[SMTP Mailer] Invalid recipient email: {recipient_email}\n")
        return

    subject = "Proxy Re-Encryption Platform Notification"
    if name_or_subj:
        if name_or_subj in ["Registration", "Pending"]:
            subject = "Registration Request Received - Pending TA Approval"
        elif name_or_subj in ["Approved", "Private_Key", "SecretKey"]:
            subject = "Account Approved - Your Cryptographic Private Key"
        else:
            subject = f"Proxy Re-Encryption Notification: {name_or_subj}"

    sys.stderr.write(f"[SMTP Mailer] Dispatching email to {recipient_email} (Subject: {subject})...\n")

    # Attempt 1: HTTPS API (Resend / Brevo / SendGrid - bypasses all cloud port blocks)
    if _send_via_http_api(subject, msg_body, recipient_email):
        return

    # Attempt 2: Live SMTP via SSL 465 / STARTTLS 587
    msg = MIMEMultipart()
    msg['From'] = f"Proxy Re-Encryption Platform <{SMTP_USER}>"
    msg['To'] = recipient_email
    msg['Subject'] = subject
    msg.attach(MIMEText(msg_body, 'plain'))

    # Method A: Try SSL on port 465
    try:
        with smtplib.SMTP_SSL(SMTP_HOST, 465, timeout=10) as server:
            server.login(SMTP_USER, SMTP_PASS)
            server.sendmail(SMTP_USER, recipient_email, msg.as_string())
        sys.stderr.write(f"[SMTP Mailer] SUCCESS (SSL 465): Delivered to {recipient_email}\n")
        return
    except Exception as ex1:
        sys.stderr.write(f"[SMTP Mailer Note] SSL 465 attempt ({ex1}). Retrying with STARTTLS 587...\n")

    # Method B: Try STARTTLS on port 587
    try:
        with smtplib.SMTP(SMTP_HOST, 587, timeout=10) as server:
            server.starttls()
            server.login(SMTP_USER, SMTP_PASS)
            server.sendmail(SMTP_USER, recipient_email, msg.as_string())
        sys.stderr.write(f"[SMTP Mailer] SUCCESS (STARTTLS 587): Delivered to {recipient_email}\n")
        return
    except Exception as ex2:
        sys.stderr.write(f"[SMTP Mailer Error] Live delivery failed on 465 & 587: {ex2}\n")

def secret_mail(msg_body: str, name_or_subj: str, recipient_email: str) -> bool:
    """
    Non-blocking async email dispatch. Launches background thread immediately so HTTP response is instant.
    """
    t = threading.Thread(target=_deliver_email_worker, args=(msg_body, name_or_subj, recipient_email), daemon=True)
    t.start()
    return True

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
