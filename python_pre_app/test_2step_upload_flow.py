#!/usr/bin/env python3
"""
Test 2-Step 3-Block Preview & User Submission Flow:
Replicates Java uploadFile.jsp -> uploadFile1.jsp -> DataUpload
"""

import urllib.parse
import urllib.request
import http.cookiejar
import database

BASE_URL = "http://127.0.0.1:8000"

def test_2step_flow():
    print("===============================================================================")
    print("   TESTING 2-STEP 3-BLOCK FRAGMENT PREVIEW & USER SUBMISSION WORKFLOW")
    print("===============================================================================\n")

    # Clear test file
    db = database.get_connection()
    c = db.cursor()
    c.execute("DELETE FROM do_files WHERE filekeyword='preview2step'")
    db.commit()

    # Get approved owner
    c.execute("SELECT email, password, private_key FROM do_reg WHERE status='Approved' LIMIT 1")
    raw = c.fetchone()
    owner = dict(raw) if raw else {}
    db.close()

    cj = http.cookiejar.CookieJar()
    opener = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(cj))

    # 1. Login as Data Owner
    data = urllib.parse.urlencode({'role': 'OWNER', 'email': owner['email'], 'password': owner['password'], 'private_key': owner['private_key']}).encode('utf-8')
    req = urllib.request.Request(f"{BASE_URL}/login", data=data, headers={'Content-Type': 'application/x-www-form-urlencoded'})
    resp = opener.open(req)
    print(f"1. Logged in as Data Owner: {resp.geturl()}")

    # 2. Step 1: Submit file to /owner/upload (Generates 3 blocks, does NOT upload automatically)
    boundary = "----WebKitFormBoundary2StepUploadTest"
    payload = []
    payload.append(f"--{boundary}".encode('utf-8'))
    payload.append(b'Content-Disposition: form-data; name="keyword"\r\n\r\npreview2step')
    payload.append(f"--{boundary}".encode('utf-8'))
    payload.append(b'Content-Disposition: form-data; name="fileToUpload"; filename="step2_test.txt"\r\nContent-Type: text/plain\r\n\r\nSample 2-step upload test payload for 3-block fragment preview verification.')
    payload.append(f"--{boundary}--\r\n".encode('utf-8'))
    body = b"\r\n".join(payload)

    upload_req = urllib.request.Request(f"{BASE_URL}/owner/upload", data=body, headers={'Content-Type': f'multipart/form-data; boundary={boundary}'})
    upload_resp = opener.open(upload_req)
    print(f"2. Step 1 Response (Redirected to 3 Block Preview): {upload_resp.geturl()}")
    assert "/owner/upload1" in upload_resp.geturl()

    # Verify 3 Block Preview Page HTML Content
    html = upload_resp.read().decode('utf-8')
    assert "3 Fragmented Block Preview" in html
    assert "Fragmented Block 1" in html
    assert "Fragmented Block 2" in html
    assert "Fragmented Block 3" in html
    assert "Block 1 SHA-256 Hash" in html
    assert "Upload" in html
    print("   Verified 3-Block Fragment Preview Page rendered with SHA-256 hashes and explicit Upload button!")

    # Verify NOT YET uploaded to database
    db = database.get_connection()
    c = db.cursor()
    c.execute("SELECT id FROM do_files WHERE filekeyword='preview2step'")
    assert c.fetchone() is None
    db.close()
    print("   Verified file is NOT in database before user clicks Upload button!")

    # 3. Step 2: User clicks "Upload to Cloud & Blockchain" (/owner/upload_confirm)
    confirm_data = urllib.parse.urlencode({'keyword': 'preview2step', 'filename': 'step2_test.txt'}).encode('utf-8')
    confirm_req = urllib.request.Request(f"{BASE_URL}/owner/upload_confirm", data=confirm_data, headers={'Content-Type': 'application/x-www-form-urlencoded'})
    confirm_resp = opener.open(confirm_req)
    print(f"3. Step 2 Response (Uploaded & Redirected): {confirm_resp.geturl()}")
    assert "File_uploaded=1" in confirm_resp.geturl()

    # Verify NOW uploaded to database & Ethereum Blockchain
    db = database.get_connection()
    c = db.cursor()
    c.execute("SELECT id, filename, hash1, hash2, hash3, tx_hash FROM do_files WHERE filekeyword='preview2step'")
    raw_file = c.fetchone()
    file_row = dict(raw_file) if raw_file else {}
    db.close()

    print(f"   Database Confirmation AFTER User Click:")
    print(f"   - File ID: {file_row.get('id')}")
    print(f"   - SHA-256 Hash 1: {file_row.get('hash1')}")
    print(f"   - SHA-256 Hash 2: {file_row.get('hash2')}")
    print(f"   - SHA-256 Hash 3: {file_row.get('hash3')}")
    print(f"   - EVM Blockchain TxHash: {file_row.get('tx_hash')}")

    assert file_row.get('id') and file_row.get('tx_hash', '').startswith('0x')

    print("\n===============================================================================")
    print("   2-STEP 3-BLOCK PREVIEW & USER SUBMISSION VERIFIED 100% SUCCESSFUL!")
    print("===============================================================================")

if __name__ == '__main__':
    test_2step_flow()
