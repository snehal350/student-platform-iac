import os
import sqlite3
from flask import Flask, jsonify, request

app = Flask(__name__)
DB_PATH = os.environ.get("DB_PATH", "/data/students.db")


def get_db():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn


def init_db():
    os.makedirs(os.path.dirname(DB_PATH), exist_ok=True)
    with get_db() as db:
        db.execute("CREATE TABLE IF NOT EXISTS students (id INTEGER PRIMARY KEY, name TEXT NOT NULL, course TEXT NOT NULL)")
        db.execute("CREATE TABLE IF NOT EXISTS marks (id INTEGER PRIMARY KEY AUTOINCREMENT, student_id INTEGER NOT NULL, subject TEXT NOT NULL, marks INTEGER NOT NULL)")
        db.executemany(
            "INSERT OR IGNORE INTO students (id, name, course) VALUES (?, ?, ?)",
            [(1, "Asha", "AIML"), (2, "Rahul", "CSE"), (3, "Meera", "AIML")],
        )


@app.get("/api/health")
def health():
    return jsonify(status="UP")


@app.get("/api/students")
def students():
    with get_db() as db:
        rows = db.execute("SELECT * FROM students").fetchall()
    return jsonify([dict(r) for r in rows])


@app.post("/api/marks")
def add_marks():
    data = request.get_json(silent=True) or {}
    try:
        sid = int(data["student_id"])
        subject = str(data["subject"])
        marks = int(data["marks"])
    except (KeyError, ValueError, TypeError):
        return jsonify(error="student_id, subject, marks are required"), 400
    with get_db() as db:
        if not db.execute("SELECT 1 FROM students WHERE id = ?", (sid,)).fetchone():
            return jsonify(error="student not found"), 404
        db.execute("INSERT INTO marks (student_id, subject, marks) VALUES (?, ?, ?)", (sid, subject, marks))
    return jsonify(status="success"), 201


init_db()
