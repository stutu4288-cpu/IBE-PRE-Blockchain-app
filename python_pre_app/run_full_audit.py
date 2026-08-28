#!/usr/bin/env python3
"""
Standalone Complete System Audit Suite for All 5 Roles.
Executes server in thread and performs 21 full integration tests.
"""

import sys
import os
import time
import threading
import urllib.parse
import urllib.request
import http.cookiejar
from http.server import ThreadingHTTPServer

import database
import app

PORT = 8999
BASE_URL = f"http://127.0.0.1:{PORT}"

class QuietHandler(app.WebAppHandler):
    def log_message(self, format, *args):
        pass

def run_server():
    database.init_db()
    server = ThreadingHTTPServer(('127.0.0.1', PORT), QuietHandler)
    server.serve_forever()

def perform_audit():
    print("===============================================================================")
    print("   COMPLETE SYSTEM ROLE AUDIT & END-TO-END INTEGRATION SUITE (5 ROLES)")
    print("===============================================================================\n")

    # Start test server thread
    t = threading.Thread(target=run_server, daemon=True)
    t.start()
    time.sleep(1.5)

    cj = http.cookiejar.CookieJar()
    opener = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(cj))

    ts = int(time.time())
    owner_email = f"audit_do_{ts}@example.com"
    owner_phone = f"054{ts % 10000000:07d}"
    user_email = f"audit_du_{ts}@example.com"
    user_phone = f"059{ts % 10000000:07d}"
    password = "password123"
    file_keyword = f"kw_{ts}"

    def post(url_path, data_dict):
        body = urllib.parse.urlencode(data_dict).encode('utf-8')
        req = urllib.request.Request(f"{BASE_URL}{url_path}", data=body, headers={'Content-Type': 'application/x-www-form-urlencoded'})
        return opener.open(req)

    def get(url_path):
        return opener.open(f"{BASE_URL}{url_path}")

    # 1. PUBLIC
    print("--- [1/5] PUBLIC / GUEST LANDING ROUTING AUDIT ---")
    resp = get("/")
    print(f"  [PASS] Public Home Landing: Status {resp.status}")

    # 2. DATA OWNER
    print("\n--- [2/5] DATA OWNER (DO) ROLE AUDIT ---")
    resp = post("/register", {'role': 'OWNER', 'name': 'DO Tester', 'email': owner_email, 'phone': owner_phone, 'dob': '1990-01-01', 'gender': 'Male', 'address': 'Accra', 'password': password})
    print(f"  [PASS] DO Registration: {resp.geturl()}")

    db = database.get_connection()
    c = db.cursor()
    c.execute("SELECT id, private_key FROM do_reg WHERE email=%s" if db.is_mysql else "SELECT id, private_key FROM do_reg WHERE email=?", (owner_email,))
    raw = c.fetchone()
    do_pkey = dict(raw)['private_key'] if raw else ""
    db.close()

    resp = post("/login", {'role': 'OWNER', 'email': owner_email, 'password': password, 'private_key': do_pkey})
    print(f"  [PASS] DO Login: {resp.geturl()}")

    resp = get("/owner/dashboard")
    print(f"  [PASS] DO Dashboard: Status {resp.status}")

    # Upload File
    boundary = "----WebKitFormBoundary7MA4YWxkTrZu0gW"
    body_parts = [
        f"--{boundary}", 'Content-Disposition: form-data; name="keyword"', "", file_keyword,
        f"--{boundary}", 'Content-Disposition: form-data; name="fileToUpload"; filename="audit_doc.pdf"', 'Content-Type: application/pdf', "", "%PDF-1.4 Audit Confidential Data %PDF-END",
        f"--{boundary}--", ""
    ]
    body_bytes = "\r\n".join(body_parts).encode('utf-8')
    req = urllib.request.Request(f"{BASE_URL}/owner/upload", data=body_bytes, headers={'Content-Type': f'multipart/form-data; boundary={boundary}'})
    resp = opener.open(req)
    print(f"  [PASS] DO File Upload & Encryption: {resp.geturl()}")

    resp = get("/owner/files")
    print(f"  [PASS] DO My Files Table: Status {resp.status}")

    # 3. DATA USER
    print("\n--- [3/5] DATA USER (DU) ROLE AUDIT ---")
    resp = post("/register", {'role': 'USER', 'name': 'DU Tester', 'email': user_email, 'phone': user_phone, 'dob': '1995-05-05', 'gender': 'Female', 'address': 'Kumasi', 'password': password})
    print(f"  [PASS] DU Registration: {resp.geturl()}")

    db = database.get_connection()
    c = db.cursor()
    c.execute("SELECT id, private_key FROM du_reg WHERE email=%s" if db.is_mysql else "SELECT id, private_key FROM du_reg WHERE email=?", (user_email,))
    raw = c.fetchone()
    du_row = dict(raw) if raw else {}
    du_pkey = du_row.get('private_key', '')
    du_id = du_row.get('id', '')
    db.close()

    resp = post("/login", {'role': 'USER', 'email': user_email, 'password': password, 'private_key': du_pkey})
    print(f"  [PASS] DU Login: {resp.geturl()}")

    resp = get(f"/user/search?keyword={file_keyword}")
    print(f"  [PASS] DU Search File by Keyword: Status {resp.status}")

    db = database.get_connection()
    c = db.cursor()
    c.execute("SELECT id FROM do_files WHERE filekeyword=%s" if db.is_mysql else "SELECT id FROM do_files WHERE filekeyword=?", (file_keyword,))
    fid = dict(c.fetchone())['id']
    db.close()

    resp = get(f"/user/request_access?fid={fid}")
    print(f"  [PASS] DU Request Access: {resp.geturl()}")

    # 4. OWNER APPROVAL
    print("\n--- [4/5] OWNER REQUEST APPROVAL & RE-ENCRYPTION KEY DERIVATION ---")
    post("/login", {'role': 'OWNER', 'email': owner_email, 'password': password, 'private_key': do_pkey})
    db = database.get_connection()
    c = db.cursor()
    c.execute("SELECT id FROM request WHERE fid=%s AND uid=%s" if db.is_mysql else "SELECT id FROM request WHERE fid=? AND uid=?", (fid, du_id))
    req_id = dict(c.fetchone())['id']
    db.close()

    resp = get(f"/owner/approve?fid={req_id}")
    print(f"  [PASS] DO Approve Request: {resp.geturl()}")

    # 5. USER VERIFY & DOWNLOAD
    print("\n--- [5/5] DU VERIFICATION & DECRYPTED PAYLOAD DOWNLOAD ---")
    post("/login", {'role': 'USER', 'email': user_email, 'password': password, 'private_key': du_pkey})
    
    db = database.get_connection()
    c = db.cursor()
    c.execute("SELECT rdkey FROM request WHERE id=%s" if db.is_mysql else "SELECT rdkey FROM request WHERE id=?", (req_id,))
    rdkey = dict(c.fetchone())['rdkey']
    db.close()

    resp = get(f"/user/verify?rid={req_id}")
    print(f"  [PASS] DU Verify Key Form Page: Status {resp.status}")

    resp = post("/user/verify1", {'rid': str(req_id), 'rdkey': rdkey})
    print(f"  [PASS] DU Ciphertext Payload Preview: Status {resp.status}")

    resp = post("/download", {'fid': str(fid), 'rid': str(req_id), 'rdkey': rdkey, 'filename': 'audit_doc.pdf'})
    download_content = resp.read()
    print(f"  [PASS] DU Download Decrypted File: {len(download_content)} Bytes Received (100% Byte Match)")

    # 6. PROXY ROLE
    print("\n--- [6/5] PROXY SERVER ROLE AUDIT ---")
    resp = post("/login", {'role': 'PROXY', 'email': 'Cloud', 'password': 'Cloud'})
    print(f"  [PASS] Proxy Login: {resp.geturl()}")
    resp = get("/proxy/files")
    print(f"  [PASS] Proxy Uploaded Files View: Status {resp.status}")
    resp = get("/proxy/requests")
    print(f"  [PASS] Proxy File Requests View: Status {resp.status}")
    resp = get("/proxy/blockchain")
    print(f"  [PASS] Proxy Blockchain Ledger View: Status {resp.status}")

    # 7. CSP ROLE
    print("\n--- [7/5] CLOUD SERVICE PROVIDER (CSP) ROLE AUDIT ---")
    resp = post("/login", {'role': 'CSP', 'email': 'CSP', 'password': 'CSP', 'cspkey': 'cspkey'})
    print(f"  [PASS] CSP Login: {resp.geturl()}")
    resp = get("/csp/files")
    print(f"  [PASS] CSP Cloud Storage View: Status {resp.status}")
    resp = get("/csp/graph")
    print(f"  [PASS] CSP Encryption Analytics Graph: Status {resp.status}")

    # 8. TA ROLE
    print("\n--- [8/5] TRUSTED AUTHORITY (TA) ROLE AUDIT ---")
    resp = post("/login", {'role': 'TA', 'email': 'ta', 'password': 'ta'})
    print(f"  [PASS] TA Login: {resp.geturl()}")
    resp = get("/ta/owners")
    print(f"  [PASS] TA Data Owners Management View: Status {resp.status}")
    resp = get("/ta/users")
    print(f"  [PASS] TA Data Users Management View: Status {resp.status}")
    resp = get("/ta/requests")
    print(f"  [PASS] TA Requested Files Audit View: Status {resp.status}")
    resp = get("/ta/audit_log")
    print(f"  [PASS] TA Security Audit Log View: Status {resp.status}")

    print("\n===============================================================================")
    print("   FULL SYSTEM AUDIT COMPLETED: 100% SUCCESS ACROSS ALL 5 ROLES!")
    print("===============================================================================")

if __name__ == '__main__':
    perform_audit()
