#!/usr/bin/env python3
"""
Admin account setup script for testing
"""
import hashlib
import pyodbc

# SHA-256 hash of "admin123"
PASSWORD = "admin123"
PASSWORD_HASH = hashlib.sha256(PASSWORD.encode()).hexdigest()

print(f"Password: {PASSWORD}")
print(f"SHA-256 Hash: {PASSWORD_HASH}")

# Connect to database
try:
    conn = pyodbc.connect(
        'Driver={ODBC Driver 17 for SQL Server};'
        'Server=localhost;'
        'Database=Project;'
        'Trusted_Connection=yes;'
    )
    cursor = conn.cursor()
    
    # Update admin account
    cursor.execute("""
        UPDATE Account 
        SET password_hash = ?, role = 'Admin', status = 'active'
        WHERE email = 'test.admin@example.com'
    """, PASSWORD_HASH)
    
    if cursor.rowcount == 0:
        # Insert if not exists
        cursor.execute("""
            INSERT INTO Account (full_name, email, password_hash, role, status, created_at)
            VALUES ('Test Admin', 'test.admin@example.com', ?, 'Admin', 'active', GETDATE())
        """, PASSWORD_HASH)
    
    conn.commit()
    print(f"Admin account updated: test.admin@example.com / admin123")
    print(f"Affected rows: {cursor.rowcount}")
    conn.close()
    
except Exception as e:
    print(f"Error: {e}")
