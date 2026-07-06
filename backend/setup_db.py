"""Create database if not exists.

Run: python setup_db.py
Requires DB_SETUP_PASSWORD env var (use the postgres superuser password).
"""
import os
import sys

import psycopg2

password = os.environ.get('DB_SETUP_PASSWORD')
if not password:
    print('DB_SETUP_PASSWORD environment variable is required.', file=sys.stderr)
    sys.exit(1)

conn = psycopg2.connect(
    dbname='postgres',
    user=os.environ.get('DB_SETUP_USER', 'postgres'),
    password=password,
    host=os.environ.get('DB_HOST', 'localhost'),
    port=os.environ.get('DB_PORT', '5432'),
)
conn.autocommit = True
cur = conn.cursor()

cur.execute("SELECT 1 FROM pg_database WHERE datname = 'anju_db'")
if cur.fetchone() is None:
    cur.execute('CREATE DATABASE anju_db')
    print('Database anju_db created successfully')
else:
    print('Database anju_db already exists')

cur.close()
conn.close()
