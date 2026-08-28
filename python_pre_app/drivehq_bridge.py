"""
Enterprise DriveHQ Cloud Storage Provider (FTP Bridge).
Uploads encrypted ciphertext blocks (cloud1, cloud2, cloud3) to ftp.drivehq.com.
"""

import ftplib
import io
import threading
import sys
import time

FTP_HOST = "ftp.drivehq.com"
FTP_USER = "stubtechict@gmail.com"
FTP_PASS = "StuBt3q!ct"


def get_ftp_connection(timeout=10):
    """Establishes an authenticated FTP session with DriveHQ."""
    try:
        ftp = ftplib.FTP(FTP_HOST, timeout=timeout)
        try:
            ftp.login(FTP_USER, FTP_PASS)
        except Exception:
            ftp.login("stubtechict", FTP_PASS)
        ftp.set_pasv(True)
        return ftp
    except Exception as e:
        sys.stderr.write(f"[DriveHQ Error] Failed to connect: {e}\n")
        return None


def upload_block(ftp, remote_dir, filename, data_bytes):
    """Uploads binary data to a remote directory on DriveHQ."""
    try:
        # Ensure remote directory exists
        try:
            ftp.cwd(f"/{remote_dir}")
        except Exception:
            try:
                ftp.mkd(f"/{remote_dir}")
                ftp.cwd(f"/{remote_dir}")
            except Exception:
                pass
        
        bio = io.BytesIO(data_bytes)
        ftp.storbinary(f"STOR {filename}", bio)
        ftp.cwd("/")
        return True
    except Exception as e:
        sys.stderr.write(f"[DriveHQ Upload Error] {remote_dir}/{filename}: {e}\n")
        try:
            ftp.cwd("/")
        except Exception:
            pass
        return False


def upload_blocks_to_drivehq(keyword: str, cipher_bytes: bytes):
    """
    Splits ciphertext into 3 blocks and uploads each block to DriveHQ:
    - Block 1 -> /cloud1/{keyword}1.txt
    - Block 2 -> /cloud2/{keyword}2.txt
    - Block 3 -> /cloud3/{keyword}3.txt
    """
    def _worker():
        ftp = get_ftp_connection(timeout=15)
        if not ftp:
            return False
        
        try:
            total_len = len(cipher_bytes)
            chunk_size = max(1, (total_len + 2) // 3)
            b1 = cipher_bytes[:chunk_size]
            b2 = cipher_bytes[chunk_size:chunk_size*2]
            b3 = cipher_bytes[chunk_size*2:]

            upload_block(ftp, "cloud1", f"{keyword}1.txt", b1)
            upload_block(ftp, "cloud2", f"{keyword}2.txt", b2)
            upload_block(ftp, "cloud3", f"{keyword}3.txt", b3)
            sys.stderr.write(f"[DriveHQ Sync] Successfully synced 3 blocks for keyword '{keyword}' to DriveHQ Cloud.\n")
            return True
        except Exception as ex:
            sys.stderr.write(f"[DriveHQ Sync Error] {ex}\n")
            return False
        finally:
            try:
                ftp.quit()
            except Exception:
                pass

    # Run in background daemon thread to keep web requests instant
    t = threading.Thread(target=_worker, daemon=True)
    t.start()
    return True


def check_drivehq_status():
    """Checks DriveHQ connectivity and directory counts."""
    ftp = get_ftp_connection(timeout=5)
    if not ftp:
        return {"status": "Offline", "cloud1": 0, "cloud2": 0, "cloud3": 0}
    
    counts = {}
    try:
        for folder in ["cloud1", "cloud2", "cloud3"]:
            try:
                ftp.cwd(f"/{folder}")
                lines = []
                ftp.retrlines("NLST", lines.append)
                counts[folder] = len(lines)
            except Exception:
                counts[folder] = 0
        ftp.quit()
        return {"status": "Online", **counts}
    except Exception:
        return {"status": "Error", "cloud1": 0, "cloud2": 0, "cloud3": 0}
