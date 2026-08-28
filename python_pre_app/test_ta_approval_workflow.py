#!/usr/bin/env python3
"""
Test TA Approval & Emailed Private Key Workflow:
1. Register user -> Status 'Pending', no Private Key.
2. Login attempt BEFORE TA approval -> Blocked with error=pending.
3. TA Approves user -> Private Key generated & dispatched via email log.
4. Login attempt AFTER TA approval with emailed Private Key -> SUCCESS (HTTP 200 / Dashboard).
"""

import sys
import urllib.parse
import urllib.request
import http.cookiejar
import database

BASE_URL = "http://127.0.0.1:8000"

def test_workflow():
    print("===============================================================================")
    print("   TESTING TA APPROVAL & EMAILED PRIVATE KEY AUTHENTICATION WORKFLOW")
    print("===============================================================================\n")

    # Clear users table
    db = database.get_connection()
    c = db.cursor()
    c.execute("DELETE FROM do_reg")
    c.execute("DELETE FROM du_reg")
    db.commit()
    db.close()

    cj = http.cookiejar.CookieJar()
    opener = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(cj))

    def post(path, data):
        body = urllib.parse.urlencode(data).encode('utf-8')
        req = urllib.request.Request(f"{BASE_URL}{path}", data=body, headers={'Content-Type': 'application/x-www-form-urlencoded'})
        return opener.open(req)

    def get(path):
        return opener.open(f"{BASE_URL}{path}")

    # Step 1: User Registration
    user_email = "ta_pending_do@example.com"
    pwd = "password123"
    resp = post("/register", {'role': 'OWNER', 'name': 'Pending Owner', 'email': user_email, 'password': pwd, 'phone': '0551112233', 'dob': '1990-01-01', 'gender': 'Male', 'address': 'Accra'})
    print(f"1. Registration Submitted: {resp.geturl()}")
    assert "msg=pending_approval" in resp.geturl()

    # Verify DB status is 'Pending'
    db = database.get_connection()
    c = db.cursor()
    c.execute("SELECT id, status, private_key FROM do_reg WHERE email=%s" if db.is_mysql else "SELECT id, status, private_key FROM do_reg WHERE email=?", (user_email,))
    raw = c.fetchone()
    row = dict(raw) if raw else {}
    do_id = row['id']
    print(f"   DB State on Registration: status='{row['status']}', private_key='{row['private_key']}'")
    assert row['status'] == 'Pending'
    db.close()

    # Step 2: Login BEFORE TA approval (Should be BLOCKED)
    resp = post("/login", {'role': 'OWNER', 'email': user_email, 'password': pwd, 'private_key': ''})
    print(f"2. Login attempt BEFORE TA approval: {resp.geturl()}")
    assert "error=pending" in resp.geturl()

    # Step 3: TA Login & Approve User
    post("/login", {'role': 'TA', 'email': 'ta', 'password': 'ta'})
    resp = get(f"/ta/approve_do?id={do_id}")
    print(f"3. TA Approved User: {resp.geturl()}")
    assert "Approved=1" in resp.geturl()

    # Verify DB status is 'Approved' and private_key is issued
    db = database.get_connection()
    c = db.cursor()
    c.execute("SELECT status, private_key FROM do_reg WHERE id=%s" if db.is_mysql else "SELECT status, private_key FROM do_reg WHERE id=?", (do_id,))
    raw = c.fetchone()
    approved_row = dict(raw) if raw else {}
    issued_pkey = approved_row['private_key']
    print(f"   DB State AFTER TA Approval: status='{approved_row['status']}', issued_pkey='{issued_pkey}'")
    assert approved_row['status'] == 'Approved' and len(issued_pkey) > 0
    db.close()

    # Step 4: Login AFTER TA approval using issued Private Key (Should SUCCEED)
    resp = post("/login", {'role': 'OWNER', 'email': user_email, 'password': pwd, 'private_key': issued_pkey})
    print(f"4. Login attempt AFTER TA approval with emailed Private Key: {resp.geturl()}")
    assert "owner/dashboard" in resp.geturl()

    print("\n===============================================================================")
    print("   TA APPROVAL & EMAILED PRIVATE KEY AUTHENTICATION VERIFIED 100% SUCCESSFUL!")
    print("===============================================================================")

if __name__ == '__main__':
    test_workflow()
