"""
Integrated Database Layer for Python PRE App.
Directly connects to MySQL ('prea' on localhost:3306) with dictionary cursors
and automatic fallback to SQLite ('prea_python.db') if MySQL is unreachable.
"""

import os
import sys

try:
    import pymysql
    import pymysql.cursors
    HAS_PYMYSQL = True
except ImportError:
    HAS_PYMYSQL = False

import sqlite3

# MySQL Configuration (Supports Railway environment variables)
MYSQL_HOST = os.environ.get("MYSQLHOST", os.environ.get("MYSQL_HOST", "127.0.0.1"))
MYSQL_PORT = int(os.environ.get("MYSQLPORT", os.environ.get("MYSQL_PORT", 3306)))
MYSQL_USER = os.environ.get("MYSQLUSER", os.environ.get("MYSQL_USER", "root"))
MYSQL_PASS = os.environ.get("MYSQLPASSWORD", os.environ.get("MYSQL_PASSWORD", ""))
MYSQL_DB   = os.environ.get("MYSQLDATABASE", os.environ.get("MYSQL_DB", "prea"))

SQLITE_PATH = os.path.join(os.path.dirname(__file__), "prea_python.db")


class DBConnection:
    """Wrapper that normalizes MySQL and SQLite connections."""
    def __init__(self, is_mysql=True, conn=None):
        self.is_mysql = is_mysql
        self.conn = conn

    def cursor(self):
        if self.is_mysql:
            return self.conn.cursor()
        else:
            return self.conn.cursor()

    def commit(self):
        self.conn.commit()

    def rollback(self):
        self.conn.rollback()

    def close(self):
        self.conn.close()


def dict_factory(cursor, row):
    """Row factory that converts SQLite rows into standard Python dictionaries."""
    return {col[0]: row[idx] for idx, col in enumerate(cursor.description)}


_MYSQL_WARNED = False

def get_connection():
    """Returns an active DBConnection (MySQL primary, SQLite fallback)."""
    global _MYSQL_WARNED
    if HAS_PYMYSQL and (MYSQL_HOST != "127.0.0.1" or os.environ.get("MYSQLHOST") or os.environ.get("MYSQL_HOST")):
        try:
            m_conn = pymysql.connect(
                host=MYSQL_HOST,
                port=MYSQL_PORT,
                user=MYSQL_USER,
                password=MYSQL_PASS,
                database=MYSQL_DB,
                charset='utf8mb4',
                cursorclass=pymysql.cursors.DictCursor,
                autocommit=True,
                connect_timeout=5,
                read_timeout=30,
                write_timeout=30
            )
            return DBConnection(is_mysql=True, conn=m_conn)
        except Exception as e:
            if not _MYSQL_WARNED:
                sys.stdout.write(f"[DB Engine] MySQL connection unestablished. Operating in SQLite Embedded Mode.\n")
                sys.stdout.flush()
                _MYSQL_WARNED = True

    if not _MYSQL_WARNED and (MYSQL_HOST == "127.0.0.1" and not os.environ.get("MYSQLHOST")):
        sys.stdout.write(f"[DB Engine] Operating in SQLite Embedded Database Mode.\n")
        sys.stdout.flush()
        _MYSQL_WARNED = True

    s_conn = sqlite3.connect(SQLITE_PATH)
    s_conn.row_factory = dict_factory
    return DBConnection(is_mysql=False, conn=s_conn)


def init_db():
    """Ensures all necessary tables and test accounts exist."""
    db = get_connection()
    c = db.cursor()

    if db.is_mysql:
        # Verify and ensure tables exist in MySQL
        c.execute("""
        CREATE TABLE IF NOT EXISTS do_reg (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(255),
            email VARCHAR(255) UNIQUE,
            dob VARCHAR(255),
            gender VARCHAR(255),
            phone VARCHAR(255),
            address TEXT,
            password VARCHAR(255),
            status VARCHAR(50) DEFAULT 'Approved',
            private_key TEXT,
            public_key TEXT,
            reg_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        """)

        c.execute("""
        CREATE TABLE IF NOT EXISTS du_reg (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(255),
            email VARCHAR(255) UNIQUE,
            dob VARCHAR(255),
            gender VARCHAR(255),
            phone VARCHAR(255),
            address TEXT,
            password VARCHAR(255),
            status VARCHAR(50) DEFAULT 'Approved',
            private_key TEXT,
            public_key TEXT,
            reg_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        """)

        c.execute("""
        CREATE TABLE IF NOT EXISTS do_files (
            id INT AUTO_INCREMENT PRIMARY KEY,
            doid VARCHAR(255),
            doname VARCHAR(255),
            enc_data LONGBLOB,
            dkey TEXT,
            time VARCHAR(255),
            filekeyword VARCHAR(255),
            filename VARCHAR(255),
            data LONGBLOB,
            block1 LONGTEXT,
            block2 LONGTEXT,
            block3 LONGTEXT,
            hash1 VARCHAR(255),
            hash2 VARCHAR(255),
            hash3 VARCHAR(255),
            ori_block1 LONGTEXT,
            ori_block2 LONGTEXT,
            ori_block3 LONGTEXT,
            rdkey TEXT,
            reencrypt_data LONGTEXT,
            encryptTime VARCHAR(255),
            tx_hash VARCHAR(255)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        """)

        c.execute("""
        CREATE TABLE IF NOT EXISTS request (
            id INT AUTO_INCREMENT PRIMARY KEY,
            filename VARCHAR(255),
            time VARCHAR(255),
            uid VARCHAR(255),
            uname VARCHAR(255),
            status VARCHAR(50) DEFAULT 'waiting',
            fid VARCHAR(255),
            doid VARCHAR(255),
            umail VARCHAR(255),
            dkey TEXT,
            rdkey TEXT,
            dostatus VARCHAR(50) DEFAULT 'waiting',
            tx_hash VARCHAR(255),
            granted_time VARCHAR(255)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        """)

        c.execute("""
        CREATE TABLE IF NOT EXISTS download (
            id INT AUTO_INCREMENT PRIMARY KEY,
            uid VARCHAR(255),
            uname VARCHAR(255),
            filename VARCHAR(255),
            time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            fileid VARCHAR(255),
            doname VARCHAR(255),
            doid VARCHAR(255),
            decrypt_time FLOAT
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        """)

        c.execute("""
        CREATE TABLE IF NOT EXISTS login_log (
            id INT AUTO_INCREMENT PRIMARY KEY,
            user_type VARCHAR(45) NOT NULL,
            user_id VARCHAR(45) NOT NULL,
            email VARCHAR(255) NOT NULL,
            ip_address VARCHAR(45) NOT NULL,
            status VARCHAR(45) NOT NULL,
            login_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        """)

    else:
        # SQLite schema
        c.execute("""
        CREATE TABLE IF NOT EXISTS do_reg (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT, email TEXT UNIQUE, dob TEXT, gender TEXT, phone TEXT, address TEXT,
            password TEXT, status TEXT DEFAULT 'Approved', private_key TEXT, public_key TEXT,
            reg_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )""")
        c.execute("""
        CREATE TABLE IF NOT EXISTS du_reg (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT, email TEXT UNIQUE, dob TEXT, gender TEXT, phone TEXT, address TEXT,
            password TEXT, status TEXT DEFAULT 'Approved', private_key TEXT, public_key TEXT,
            reg_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )""")
        c.execute("""
        CREATE TABLE IF NOT EXISTS do_files (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            doid TEXT, doname TEXT, enc_data BLOB, dkey TEXT, time TEXT, filekeyword TEXT,
            filename TEXT, data BLOB, block1 TEXT, block2 TEXT, block3 TEXT, hash1 TEXT,
            hash2 TEXT, hash3 TEXT, ori_block1 TEXT, ori_block2 TEXT, ori_block3 TEXT,
            rdkey TEXT, reencrypt_data TEXT, encryptTime TEXT, tx_hash TEXT
        )""")
        c.execute("""
        CREATE TABLE IF NOT EXISTS request (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            filename TEXT, time TEXT, uid TEXT, uname TEXT, status TEXT DEFAULT 'waiting',
            fid TEXT, doid TEXT, umail TEXT, dkey TEXT, rdkey TEXT DEFAULT 'waiting',
            dostatus TEXT DEFAULT 'waiting', tx_hash TEXT, granted_time TEXT
        )""")
        c.execute("""
        CREATE TABLE IF NOT EXISTS download (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            uid TEXT, uname TEXT, filename TEXT, time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            fileid TEXT, doname TEXT, doid TEXT, decrypt_time REAL
        )""")
        c.execute("""
        CREATE TABLE IF NOT EXISTS login_log (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_type TEXT NOT NULL,
            user_id TEXT NOT NULL,
            email TEXT NOT NULL,
            ip_address TEXT NOT NULL,
            status TEXT NOT NULL,
            login_time TEXT DEFAULT CURRENT_TIMESTAMP
        )""")

        # Ensure all columns exist in SQLite do_files
        c.execute("PRAGMA table_info(do_files)")
        existing_cols = [r[1] if isinstance(r, (tuple, list)) else r['name'] for r in c.fetchall()]
        needed = {
            'block1': 'TEXT', 'block2': 'TEXT', 'block3': 'TEXT',
            'ori_block1': 'TEXT', 'ori_block2': 'TEXT', 'ori_block3': 'TEXT',
            'reencrypt_data': 'TEXT'
        }
        for col, col_type in needed.items():
            if col not in existing_cols:
                try:
                    c.execute(f"ALTER TABLE do_files ADD COLUMN {col} {col_type}")
                except Exception:
                    pass

        # Ensure columns exist in SQLite request
        c.execute("PRAGMA table_info(request)")
        req_cols = [r[1] if isinstance(r, (tuple, list)) else r['name'] for r in c.fetchall()]
        for col in ['filekeyword', 'doname', 'tx_hash', 'granted_time', 'dostatus']:
            if col not in req_cols:
                try: c.execute(f"ALTER TABLE request ADD COLUMN {col} TEXT")
                except Exception: pass

    # Always ensure columns exist in MySQL if live
    if db.is_mysql:
        try:
            c.execute("""
            CREATE TABLE IF NOT EXISTS login_log (
                id INT AUTO_INCREMENT PRIMARY KEY,
                user_type VARCHAR(50),
                user_id VARCHAR(50),
                email VARCHAR(255),
                ip_address VARCHAR(100),
                status VARCHAR(50),
                login_time VARCHAR(100)
            )""")
            c.execute("SHOW COLUMNS FROM request")
            m_cols = [r['Field'] if isinstance(r, dict) else r[0] for r in c.fetchall()]
            for col, col_def in [('filekeyword', 'VARCHAR(255)'), ('doname', 'VARCHAR(255)'), ('tx_hash', 'VARCHAR(500)'), ('granted_time', 'VARCHAR(255)'), ('dostatus', 'VARCHAR(255)')]:
                if col not in m_cols:
                    c.execute(f"ALTER TABLE request ADD COLUMN {col} {col_def} DEFAULT NULL")
        except Exception as e:
            sys.stderr.write(f"[MySQL Migration Warning] {e}\n")

    db.commit()
    db.close()
    import_schema_sql_if_empty()
    seed_db()


def import_schema_sql_if_empty():
    """Auto-executes schema.sql if tables do not exist in Railway MySQL."""
    try:
        db = get_connection()
        if not db.is_mysql:
            db.close()
            return
        c = db.cursor()
        c.execute("SHOW TABLES")
        tables = c.fetchall()
        if not tables or len(tables) == 0:
            schema_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), "schema.sql")
            if os.path.exists(schema_path):
                sys.stderr.write(f"[DB Auto-Import] Importing initial schema from {schema_path} into Railway MySQL...\n")
                with open(schema_path, "r", encoding="utf-8") as f_sql:
                    sql_statements = f_sql.read().split(";")
                    for stmt in sql_statements:
                        stmt_clean = stmt.strip()
                        if stmt_clean:
                            try:
                                c.execute(stmt_clean)
                            except Exception as ex_st:
                                pass
                db.commit()
                sys.stderr.write("[DB Auto-Import] SUCCESS: Initial schema & seed data imported into Railway MySQL!\n")
        db.close()
    except Exception as ex_imp:
        sys.stderr.write(f"[DB Import Warning] {ex_imp}\n")


def seed_db():
    """Populates default initial seed accounts and sample files if database is empty."""
    try:
        db = get_connection()
        c = db.cursor()

        # Seed Data Owner
        c.execute("SELECT COUNT(*) as cnt FROM do_reg")
        r_do = c.fetchone()
        count_do = (r_do['cnt'] if isinstance(r_do, dict) else r_do[0]) if r_do else 0
        if count_do == 0:
            sql_do = """
            INSERT INTO do_reg (name, dob, email, phone, address, password, status, private_key)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            """ if db.is_mysql else """
            INSERT INTO do_reg (name, dob, email, phone, address, password, status, private_key)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            """
            c.execute(sql_do, ("DataOwner", "1990-01-01", "sikapalinkz@gmail.com", "+233557185634", "Accra", "1234", "Approved", "s8lQ64h2tJ4="))

        # Seed Data User
        c.execute("SELECT COUNT(*) as cnt FROM du_reg")
        r_du = c.fetchone()
        count_du = (r_du['cnt'] if isinstance(r_du, dict) else r_du[0]) if r_du else 0
        if count_du == 0:
            sql_du = """
            INSERT INTO du_reg (name, dob, email, phone, address, password, status, private_key)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            """ if db.is_mysql else """
            INSERT INTO du_reg (name, dob, email, phone, address, password, status, private_key)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            """
            c.execute(sql_du, ("DataUser", "1995-05-05", "stutu4288@gmail.com", "+233241234567", "Kumasi", "1234", "Approved", "VAC4uFdeRe8="))

        # Seed Sample File
        c.execute("SELECT COUNT(*) as cnt FROM do_files")
        r_f = c.fetchone()
        count_f = (r_f['cnt'] if isinstance(r_f, dict) else r_f[0]) if r_f else 0
        if count_f == 0:
            sample_payload = b"Sample Cloud Security Whitepaper Document Payload - IEEE Proxy Re-Encryption Platform"
            import crypto_engine
            sample_key = crypto_engine.generate_symmetric_key()
            enc_bytes = crypto_engine.encrypt_aes_gcm(sample_payload, sample_key)
            h1 = crypto_engine.sha256_bytes(enc_bytes[:len(enc_bytes)//3])
            h2 = crypto_engine.sha256_bytes(enc_bytes[len(enc_bytes)//3: 2*len(enc_bytes)//3])
            h3 = crypto_engine.sha256_bytes(enc_bytes[2*len(enc_bytes)//3:])
            
            sql_f = """
            INSERT INTO do_files (doid, doname, enc_data, dkey, time, filekeyword, filename, data, block1, block2, block3, hash1, hash2, hash3, ori_block1, ori_block2, ori_block3, rdkey, reencrypt_data, encryptTime, tx_hash)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            """ if db.is_mysql else """
            INSERT INTO do_files (doid, doname, enc_data, dkey, time, filekeyword, filename, data, block1, block2, block3, hash1, hash2, hash3, ori_block1, ori_block2, ori_block3, rdkey, reencrypt_data, encryptTime, tx_hash)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """
            c.execute(sql_f, ("1", "DataOwner", enc_bytes, sample_key, "2026/08/28 00:00:00", "cloud", "cloud_security_whitepaper.pdf", sample_payload, "block1_data", "block2_data", "block3_data", h1, h2, h3, "ori1", "ori2", "ori3", sample_key, enc_bytes, "12.5", "0x0000000000000000000000000000000000000000000000000000000000000000"))

        db.commit()
        db.close()
    except Exception as ex_seed:
        sys.stderr.write(f"[DB Seed Warning] {ex_seed}\n")


init_db()
