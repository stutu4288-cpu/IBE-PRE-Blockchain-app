#!/usr/bin/env python3
"""
Automated HTTP E2E Test Suite for User & Owner Registration and Login.
"""

import sys
import time
import urllib.parse
import urllib.request
import http.cookiejar
import database
import app

BASE_URL = "http://127.0.0.1:8000"

def test_registration_flow():
    print("===============================================================================")
    print("   AUTOMATED E2E VERIFICATION OF USER & OWNER REGISTRATION FLOW")
    print("===============================================================================\n")

    # Ensure DB is initialized
    database.init_db()
    
    # Setup HTTP client with cookie jar
    cj = http.cookiejar.CookieJar()
    opener = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(cj))

    ts = int(time.time())
    owner_email = f"owner_test_{ts}@example.com"
    owner_phone = f"055{ts % 10000000:07d}"
    user_email = f"user_test_{ts}@example.com"
    user_phone = f"056{ts % 10000000:07d}"
    password = "password123"

    print(f"[1/5] Registering new Data Owner ({owner_email})...")
    payload_owner = urllib.parse.urlencode({
        'role': 'OWNER',
        'name': 'Test Owner',
        'email': owner_email,
        'phone': owner_phone,
        'dob': '1995-05-15',
        'gender': 'Male',
        'address': 'Accra, Ghana',
        'password': password
    }).encode('utf-8')

    req = urllib.request.Request(f"{BASE_URL}/register", data=payload_owner, headers={'Content-Type': 'application/x-www-form-urlencoded'})
    try:
        resp = opener.open(f"{BASE_URL}/register", data=payload_owner)
        final_url = resp.geturl()
        print(f"      Redirected to: {final_url}")
        if "msg=registered" in final_url:
            print("      [PASS] Data Owner registered successfully!")
        else:
            print(f"      ✖ FAILED: Expected msg=registered, got {final_url}")
            sys.exit(1)
    except Exception as e:
        print(f"      ✖ HTTP Request Error: {e}")
        sys.exit(1)

    print(f"\n[2/5] Registering new Data User ({user_email})...")
    payload_user = urllib.parse.urlencode({
        'role': 'USER',
        'name': 'Test User',
        'email': user_email,
        'phone': user_phone,
        'dob': '1998-08-20',
        'gender': 'Female',
        'address': 'Kumasi, Ghana',
        'password': password
    }).encode('utf-8')

    try:
        resp = opener.open(f"{BASE_URL}/register", data=payload_user)
        final_url = resp.geturl()
        print(f"      Redirected to: {final_url}")
        if "msg=registered" in final_url:
            print("      [PASS] Data User registered successfully!")
        else:
            print(f"      [FAIL] Expected msg=registered, got {final_url}")
            sys.exit(1)
    except Exception as e:
        print(f"      [FAIL] HTTP Request Error: {e}")
        sys.exit(1)

    print(f"\n[3/5] Testing Duplicate Email Registration ({user_email})...")
    try:
        resp = opener.open(f"{BASE_URL}/register", data=payload_user)
        final_url = resp.geturl()
        print(f"      Redirected to: {final_url}")
        if "error=email_exists" in final_url or "error=exists" in final_url:
            print("      [PASS] Duplicate email correctly blocked!")
        else:
            print(f"      [FAIL] Expected duplicate warning, got {final_url}")
            sys.exit(1)
    except Exception as e:
        print(f"      [FAIL] HTTP Request Error: {e}")
        sys.exit(1)

    print(f"\n[4/5] Logging in as Data Owner ({owner_email})...")
    db = database.get_connection()
    c = db.cursor()
    c.execute("SELECT private_key FROM do_reg WHERE email=%s" if db.is_mysql else "SELECT private_key FROM do_reg WHERE email=?", (owner_email,))
    row_owner = c.fetchone()
    owner_pkey = row_owner['private_key'] if row_owner else ""
    db.close()

    payload_owner_login = urllib.parse.urlencode({
        'role': 'OWNER',
        'email': owner_email,
        'password': password,
        'private_key': owner_pkey
    }).encode('utf-8')

    try:
        resp = opener.open(f"{BASE_URL}/login", data=payload_owner_login)
        final_url = resp.geturl()
        print(f"      Redirected to: {final_url}")
        if "owner/dashboard" in final_url:
            print("      [PASS] Data Owner logged in successfully!")
        else:
            print(f"      [FAIL] Expected owner/dashboard, got {final_url}")
            sys.exit(1)
    except Exception as e:
        print(f"      [FAIL] HTTP Request Error: {e}")
        sys.exit(1)

    print(f"\n[5/5] Logging in as Data User ({user_email})...")
    db = database.get_connection()
    c = db.cursor()
    c.execute("SELECT private_key FROM du_reg WHERE email=%s" if db.is_mysql else "SELECT private_key FROM du_reg WHERE email=?", (user_email,))
    row_user = c.fetchone()
    user_pkey = row_user['private_key'] if row_user else ""
    db.close()

    payload_user_login = urllib.parse.urlencode({
        'role': 'USER',
        'email': user_email,
        'password': password,
        'private_key': user_pkey
    }).encode('utf-8')

    try:
        resp = opener.open(f"{BASE_URL}/login", data=payload_user_login)
        final_url = resp.geturl()
        print(f"      Redirected to: {final_url}")
        if "user/dashboard" in final_url:
            print("      [PASS] Data User logged in successfully!")
        else:
            print(f"      [FAIL] Expected user/dashboard, got {final_url}")
            sys.exit(1)
    except Exception as e:
        print(f"      ✖ HTTP Request Error: {e}")
        sys.exit(1)

    print("\n===============================================================================")
    print("   REGISTRATION & LOGIN E2E VERIFICATION PASSED 100%!")
    print("===============================================================================")

if __name__ == '__main__':
    test_registration_flow()
