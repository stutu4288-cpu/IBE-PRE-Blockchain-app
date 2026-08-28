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


def get_connection():
    """Returns an active DBConnection (MySQL primary, SQLite fallback)."""
    if HAS_PYMYSQL:
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
                connect_timeout=10,
                read_timeout=30,
                write_timeout=30
            )
            return DBConnection(is_mysql=True, conn=m_conn)
        except Exception as e:
            sys.stderr.write(f"[DB Warning] MySQL unreachable ({e}), falling back to SQLite.\n")

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


init_db()
