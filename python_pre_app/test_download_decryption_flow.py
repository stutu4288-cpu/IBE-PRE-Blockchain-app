"""
E2E Test Script for Data User File Download & PRE Decryption.
"""

import sys
import urllib.request
import urllib.parse
import http.cookiejar
import database
import crypto_engine

BASE_URL = "http://127.0.0.1:8000"

def test_download():
    print("=" * 80)
    print("   TESTING DATA USER FILE DOWNLOAD & DECRYPTION FLOW")
    print("=" * 80)

    # 1. Prepare test file & request in database
    db = database.get_connection()
    c = db.cursor()

    raw_payload = b"Hello, this is a secret PRE encrypted file content for testing!"
    master_key_b64 = crypto_engine.generate_symmetric_key()
    cipher_bytes = crypto_engine.encrypt_aes_gcm(raw_payload, master_key_b64)

    # Clean old records
    c.execute("DELETE FROM do_files WHERE filekeyword='dltestkw'")
    c.execute("DELETE FROM du_reg WHERE email='downloaduser@gmail.com'")
    c.execute("DELETE FROM request WHERE umail='downloaduser@gmail.com'")
    db.commit()

    # Register Data User
    sql_u = "INSERT INTO du_reg (name, dob, email, phone, address, password, status, private_key) VALUES (%s, %s, %s, %s, %s, %s, %s, %s)" if db.is_mysql else "INSERT INTO du_reg (name, dob, email, phone, address, password, status, private_key) VALUES (?, ?, ?, ?, ?, ?, ?, ?)"
    priv_key, pub_key = crypto_engine.generate_key_pair("downloaduser@gmail.com")
    c.execute(sql_u, ("DownloadUser", "1992-02-02", "downloaduser@gmail.com", "1122334455", "Addr", "pass123", "Approved", priv_key))
    user_id = c.lastrowid or 10

    # Insert DO File
    sql_f = """
    INSERT INTO do_files (doid, doname, enc_data, dkey, time, filekeyword, filename, data, block1, block2, block3, hash1, hash2, hash3, ori_block1, ori_block2, ori_block3, rdkey, reencrypt_data, encryptTime, tx_hash)
    VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
    """ if db.is_mysql else """
    INSERT INTO do_files (doid, doname, enc_data, dkey, time, filekeyword, filename, data, block1, block2, block3, hash1, hash2, hash3, ori_block1, ori_block2, ori_block3, rdkey, reencrypt_data, encryptTime, tx_hash)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    """
    c.execute(sql_f, ("1", "DataOwner", cipher_bytes, master_key_b64, "2026/08/28 01:00:00", "dltestkw", "secret_doc.txt", raw_payload, "b1", "b2", "b3", "h1", "h2", "h3", "ob1", "ob2", "ob3", master_key_b64, cipher_bytes, "10.0", "0xtx_dl"))
    file_id = c.lastrowid or 50

    # Derive Re-Decryption key for user
    rdkey_b64 = crypto_engine.derive_user_rekey(master_key_b64, priv_key, str(user_id))

    # Insert Approved Request
    sql_req = """
    INSERT INTO request (uid, uname, umail, filename, filekeyword, time, fid, doid, doname, dkey, status, dostatus, rdkey, tx_hash)
    VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, 'Approved', 'Approved', %s, '0xtx_access')
    """ if db.is_mysql else """
    INSERT INTO request (uid, uname, umail, filename, filekeyword, time, fid, doid, doname, dkey, status, dostatus, rdkey, tx_hash)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'Approved', 'Approved', ?, '0xtx_access')
    """
    c.execute(sql_req, (str(user_id), "DownloadUser", "downloaduser@gmail.com", "secret_doc.txt", "dltestkw", "2026/08/28 01:05:00", str(file_id), "1", "DataOwner", master_key_b64, rdkey_b64))
    req_id = c.lastrowid or 80
    db.commit()
    db.close()

    print(f"1. Created Test User ({user_id}), File ({file_id}), and Approved Request ({req_id})")

    # 2. Log in as Data User
    cj = http.cookiejar.CookieJar()
    client = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(cj))
    login_data = urllib.parse.urlencode({'email': 'downloaduser@gmail.com', 'password': 'pass123', 'role': 'user'}).encode('utf-8')
    res_login = client.open(f"{BASE_URL}/login", login_data)
    assert res_login.status == 200
    print("2. Data User logged in successfully.")

    # 3. Download File via /download?fid={file_id}&rdkey={rdkey_b64}
    download_url = f"{BASE_URL}/download?fid={file_id}&rdkey={urllib.parse.quote(rdkey_b64)}"
    res_dl = client.open(download_url)
    assert res_dl.status == 200
    downloaded_data = res_dl.read()

    print(f"3. Download Response Code: {res_dl.status}")
    print(f"   Downloaded Bytes Length: {len(downloaded_data)}")
    print(f"   Decrypted Content Match: {downloaded_data == raw_payload}")
    assert downloaded_data == raw_payload

    print("=" * 80)
    print("   FILE DOWNLOAD & PRE DECRYPTION VERIFIED 100% SUCCESSFUL!")
    print("=" * 80)

if __name__ == "__main__":
    test_download()
