#!/usr/bin/env python3
"""
Test 3-Block Upload & Blockchain Logging:
Replicates Java SplitFile.java & DataUpload.java
"""

import urllib.parse
import urllib.request
import http.cookiejar
import database
import json

BASE_URL = "http://127.0.0.1:8000"

def test_upload():
    print("===============================================================================")
    print("   TESTING 3-BLOCK FILE SPLITTING & BLOCKCHAIN INTEGRITY LOGGING")
    print("===============================================================================\n")

    # Clear files table
    db = database.get_connection()
    c = db.cursor()
    c.execute("DELETE FROM do_files WHERE filekeyword='test3blk'")
    db.commit()

    # Get approved Data Owner
    c.execute("SELECT email, password, private_key FROM do_reg WHERE status='Approved' LIMIT 1")
    raw = c.fetchone()
    if not raw:
        print("No approved Data Owner found. Registering & approving test owner...")
        c.execute("INSERT INTO do_reg (name, email, password, private_key, status) VALUES ('Test Owner', 'owner3blk@test.com', '1234', 'pkey123', 'Approved')")
        db.commit()
        owner_email = "owner3blk@test.com"
        pwd = "1234"
        pkey = "pkey123"
    else:
        owner = dict(raw)
        owner_email = owner['email']
        pwd = owner['password']
        pkey = owner['private_key']
    db.close()

    cj = http.cookiejar.CookieJar()
    opener = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(cj))

    # 1. Login as Data Owner
    data = urllib.parse.urlencode({'role': 'OWNER', 'email': owner_email, 'password': pwd, 'private_key': pkey}).encode('utf-8')
    req = urllib.request.Request(f"{BASE_URL}/login", data=data, headers={'Content-Type': 'application/x-www-form-urlencoded'})
    resp = opener.open(req)
    print(f"1. Logged in as Data Owner: {resp.geturl()}")

    # 2. Upload file via multipart/form-data
    boundary = "----WebKitFormBoundary7MA4YWxkTrZu0gW"
    payload = []
    payload.append(f"--{boundary}".encode('utf-8'))
    payload.append(b'Content-Disposition: form-data; name="keyword"\r\n\r\ntest3blk')
    payload.append(f"--{boundary}".encode('utf-8'))
    payload.append(b'Content-Disposition: form-data; name="fileToUpload"; filename="blockchain_doc.txt"\r\nContent-Type: text/plain\r\n\r\nHello World! This is a test file to demonstrate 3-block file splitting and Ethereum blockchain smart contract recording in Python PRE application.')
    payload.append(f"--{boundary}--\r\n".encode('utf-8'))
    body = b"\r\n".join(payload)

    upload_req = urllib.request.Request(f"{BASE_URL}/owner/upload", data=body, headers={'Content-Type': f'multipart/form-data; boundary={boundary}'})
    upload_resp = opener.open(upload_req)
    print(f"2. File Upload Response: {upload_resp.geturl()}")

    # 3. Inspect DB row for 3-block splitting & EVM TxHash
    db = database.get_connection()
    c = db.cursor()
    c.execute("SELECT id, filename, block1, block2, block3, hash1, hash2, hash3, tx_hash FROM do_files WHERE filekeyword='test3blk'")
    raw_file = c.fetchone()
    file_row = dict(raw_file) if raw_file else {}
    db.close()

    print("\n   VERIFIED DATABASE 3-BLOCK RECORDING:")
    print(f"   - File ID: {file_row.get('id')}")
    print(f"   - Filename: {file_row.get('filename')}")
    print(f"   - Block 1 Base64 Len: {len(file_row.get('block1', ''))}")
    print(f"   - Block 2 Base64 Len: {len(file_row.get('block2', ''))}")
    print(f"   - Block 3 Base64 Len: {len(file_row.get('block3', ''))}")
    print(f"   - SHA-256 Hash 1: {file_row.get('hash1')}")
    print(f"   - SHA-256 Hash 2: {file_row.get('hash2')}")
    print(f"   - SHA-256 Hash 3: {file_row.get('hash3')}")
    print(f"   - EVM Blockchain TxHash: {file_row.get('tx_hash')}")

    assert file_row.get('block1') and file_row.get('block2') and file_row.get('block3')
    assert file_row.get('hash1') and file_row.get('hash2') and file_row.get('hash3')
    assert file_row.get('tx_hash', '').startswith('0x')

    print("\n===============================================================================")
    print("   3-BLOCK FILE SPLITTING & BLOCKCHAIN METHOD VERIFIED 100% SUCCESSFUL!")
    print("===============================================================================")

if __name__ == '__main__':
    test_upload()
