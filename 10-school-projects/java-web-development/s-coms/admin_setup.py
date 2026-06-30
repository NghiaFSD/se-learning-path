#!/usr/bin/env python3
"""
Admin account setup script for testing
"""
import hashlib
import pyodbc
import base64
import os
import configparser
import binascii

# PBKDF2 parameters must match PasswordUtil.java
PBKDF2_ITERATIONS = 100_000
SALT_LENGTH = 16
DKLEN = 32

PASSWORD = os.environ.get('ADMIN_PASSWORD', 'admin123')

def pbkdf2_hash(password: str, iterations=PBKDF2_ITERATIONS, salt_len=SALT_LENGTH, dklen=DKLEN) -> str:
    if password is None:
        password = ''
    salt = os.urandom(salt_len)
    dk = hashlib.pbkdf2_hmac('sha256', password.encode('utf-8'), salt, iterations, dklen)
    return f"pbkdf2${iterations}${base64.b64encode(salt).decode()}${base64.b64encode(dk).decode()}"

PASSWORD_HASH = pbkdf2_hash(PASSWORD)

print(f"Generated PBKDF2 hash for admin (do not share raw password)")
print(f"Password hash: {PASSWORD_HASH}")

def load_db_props():
    # Try classpath/deployed location first, then src/db.properties
    candidates = [
        os.path.join('web', 'WEB-INF', 'classes', 'db.properties'),
        os.path.join('src', 'db.properties'),
        'db.properties'
    ]
    cfg = {}
    for p in candidates:
        if os.path.exists(p):
            cp = configparser.ConfigParser()
            # configparser expects sections; prepend a fake section
            with open(p, 'r', encoding='utf-8') as f:
                content = f.read()
            content = '[default]\n' + content
            cp.read_string(content)
            cfg = dict(cp['default'])
            return cfg
    return cfg

db = load_db_props()

# Build ODBC connection string
if db.get('db.user') and db.get('db.password') and db.get('db.url'):
    # Parse db.url for server and database
    url = db.get('db.url')
    # naive parse: jdbc:sqlserver://host:1433;databaseName=Project;...
    server = 'localhost'
    database = ''
    try:
        after = url.split('://',1)[1]
        parts = after.split(';')
        server = parts[0]
        for part in parts:
            if part.lower().startswith('databasename='):
                database = part.split('=',1)[1]
    except Exception:
        pass
    conn_str = (
        'Driver={ODBC Driver 17 for SQL Server};'
        f'Server={server};'
        f'Database={database};'
        f'UID={db.get("db.user")};PWD={db.get("db.password")};'
        'Encrypt=yes;TrustServerCertificate=yes;'
    )
else:
    # fallback to trusted connection (local dev)
    conn_str = (
        'Driver={ODBC Driver 17 for SQL Server};'
        'Server=localhost;'
        "Database=Project;"
        'Trusted_Connection=yes;'
    )

try:
    conn = pyodbc.connect(conn_str)
    cursor = conn.cursor()

    # Update admin account
    cursor.execute(
        """
        UPDATE Account 
        SET password_hash = ?, role = 'Admin', status = 'active'
        WHERE email = 'test.admin@example.com'
    """,
        PASSWORD_HASH
    )

    if cursor.rowcount == 0:
        # Insert if not exists
        cursor.execute(
            """
            INSERT INTO Account (full_name, email, password_hash, role, status, created_at)
            VALUES ('Test Admin', 'test.admin@example.com', ?, 'Admin', 'active', GETDATE())
        """,
            PASSWORD_HASH
        )

    conn.commit()
    print(f"Admin account upserted: test.admin@example.com")
    print(f"Affected rows: {cursor.rowcount}")
    conn.close()

except Exception as e:
    print(f"Error: {e}")
