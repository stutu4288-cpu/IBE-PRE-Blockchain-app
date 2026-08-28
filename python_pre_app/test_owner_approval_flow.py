"""
E2E Verification Test Script for Data Owner Request Approval Flow.
"""

import sys
import urllib.request
import urllib.parse
import http.cookiejar
import re
import time
import database

BASE_URL = "http://127.0.0.1:8000"

def create_client():
    cj = http.cookiejar.CookieJar()
    opener = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(cj))
    return opener

def test_do_approval_flow():
    print("=" * 80)
    print("   TESTING DATA OWNER FILE ACCESS REQUEST APPROVAL WORKFLOW")
    print("=" * 80)

    # 1. Setup Data Owner in DB
    db = database.get_connection()
    c = db.cursor()
    
    # Clean old test records
    c.execute("DELETE FROM do_reg WHERE email='do_approve_test@gmail.com'")
    c.execute("DELETE FROM du_reg WHERE email='du_approve_test@gmail.com'")
    c.execute("DELETE FROM do_files WHERE filekeyword='approvalkw'")
    c.execute("DELETE FROM request WHERE umail='du_approve_test@gmail.com'")
    db.commit()

    # Register & approve DO
    sql_do = "INSERT INTO do_reg (name, dob, email, phone, address, password, status, private_key) VALUES (%s, %s, %s, %s, %s, %s, %s, %s)" if db.is_mysql else "INSERT INTO do_reg (name, dob, email, phone, address, password, status, private_key) VALUES (?, ?, ?, ?, ?, ?, ?, ?)"
    c.execute(sql_do, ("OwnerTest", "1990-01-01", "do_approve_test@gmail.com", "1234567890", "Address", "pass123", "Approved", "DO_PRIV_KEY_123"))
    do_id = c.lastrowid or 1

    # Register & approve DU
    sql_du = "INSERT INTO du_reg (name, dob, email, phone, address, password, status, private_key) VALUES (%s, %s, %s, %s, %s, %s, %s, %s)" if db.is_mysql else "INSERT INTO du_reg (name, dob, email, phone, address, password, status, private_key) VALUES (?, ?, ?, ?, ?, ?, ?, ?)"
    c.execute(sql_du, ("UserTest", "1995-05-05", "du_approve_test@gmail.com", "0987654321", "User Address", "pass123", "Approved", "DU_PRIV_KEY_456"))
    du_id = c.lastrowid or 1

    # Insert test file uploaded by DO
    sql_f = """
    INSERT INTO do_files (doid, doname, enc_data, dkey, time, filekeyword, filename, data, block1, block2, block3, hash1, hash2, hash3, ori_block1, ori_block2, ori_block3, rdkey, reencrypt_data, encryptTime, tx_hash)
    VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
    """ if db.is_mysql else """
    INSERT INTO do_files (doid, doname, enc_data, dkey, time, filekeyword, filename, data, block1, block2, block3, hash1, hash2, hash3, ori_block1, ori_block2, ori_block3, rdkey, reencrypt_data, encryptTime, tx_hash)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    """
    c.execute(sql_f, (str(do_id), "OwnerTest", b"encrypted_payload", "MASTER_KEY_XYZ", time.strftime('%Y/%m/%d %H:%M:%S'), "approvalkw", "test_file.txt", b"raw_payload", "b1", "b2", "b3", "h1", "h2", "h3", "ob1", "ob2", "ob3", "MASTER_KEY_XYZ", b"encrypted_payload", "12.5", "0xtx123"))
    file_id = c.lastrowid or 1

    # Insert pending request from DU to DO
    sql_req = """
    INSERT INTO request (uid, uname, umail, filename, filekeyword, time, fid, doid, doname, dkey, status, dostatus, rdkey)
    VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, 'waiting', 'waiting', 'waiting')
    """ if db.is_mysql else """
    INSERT INTO request (uid, uname, umail, filename, filekeyword, time, fid, doid, doname, dkey, status, dostatus, rdkey)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'waiting', 'waiting', 'waiting')
    """
    c.execute(sql_req, (str(du_id), "UserTest", "du_approve_test@gmail.com", "test_file.txt", "approvalkw", time.strftime('%Y/%m/%d %H:%M:%S'), str(file_id), str(do_id), "OwnerTest", "MASTER_KEY_XYZ"))
    req_id = c.lastrowid or 1
    db.commit()
    db.close()

    print(f"1. Prepared DO (ID: {do_id}), DU (ID: {du_id}), File (ID: {file_id}), Request (ID: {req_id})")

    # 2. Log in as Data Owner
    do_client = create_client()
    login_data = urllib.parse.urlencode({
        'email': 'do_approve_test@gmail.com',
        'password': 'pass123',
        'role': 'owner'
    }).encode('utf-8')
    res = do_client.open(f"{BASE_URL}/login", login_data)
    assert res.status == 200
    print("2. Logged in successfully as Data Owner.")

    # 3. View Requested Files page
    res_req = do_client.open(f"{BASE_URL}/owner/requests")
    req_html = res_req.read().decode('utf-8')
    assert "test_file.txt" in req_html
    assert "UserTest" in req_html
    print("3. Verified incoming request visible in Data Owner's /owner/requests table!")

    # 4. Data Owner approves request via /owner/approve?fid={req_id}
    res_app = do_client.open(f"{BASE_URL}/owner/approve?fid={req_id}")
    assert res_app.status == 200
    print("4. Executed Data Owner approval action (/owner/approve?fid=...)!")

    # 5. Verify status in database
    db2 = database.get_connection()
    c2 = db2.cursor()
    c2.execute("SELECT * FROM request WHERE id=%s" if db2.is_mysql else "SELECT * FROM request WHERE id=?", (req_id,))
    row = dict(c2.fetchone())
    db2.close()

    print(f"5. DB Verification after Data Owner Approval:")
    print(f"   - Request ID: {row['id']}")
    print(f"   - Status: {row['status']}")
    print(f"   - DO Status: {row['dostatus']}")
    print(f"   - Derived Re-Decryption Key (rdkey): {row['rdkey']}")
    print(f"   - Blockchain TxHash: {row['tx_hash']}")

    assert row['status'] == "Approved"
    assert row['dostatus'] == "Approved"
    assert row['rdkey'] and row['rdkey'] != "waiting"
    assert row['tx_hash']

    print("=" * 80)
    print("   DATA OWNER REQUEST APPROVAL WORKFLOW VERIFIED 100% SUCCESSFUL!")
    print("=" * 80)

if __name__ == "__main__":
    test_do_approval_flow()
