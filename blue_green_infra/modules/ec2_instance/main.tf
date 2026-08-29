resource "aws_instance" "blue_ec2_instance" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.public_subnet_1_id
  vpc_security_group_ids = [var.blue_ec2_sg_id]

  user_data = <<-EOF
#!/bin/bash

set -e

# ==========================================
# 1. Update and upgrade Ubuntu
# ==========================================

export DEBIAN_FRONTEND=noninteractive

apt-get update -y
apt-get upgrade -y

# ==========================================
# 2. Install required packages
# ==========================================

apt-get install -y \
    nginx \
    python3 \
    python3-pip \
    python3-venv \
    sqlite3 \
    curl

# ==========================================
# 3. Create application user
# ==========================================

useradd --system --create-home --shell /usr/sbin/nologin webapp || true

# ==========================================
# 4. Create application directory
# ==========================================

mkdir -p /opt/webapp
chown -R webapp:webapp /opt/webapp

# ==========================================
# 5. Create Python virtual environment
# ==========================================

python3 -m venv /opt/webapp/venv

/opt/webapp/venv/bin/pip install --upgrade pip
/opt/webapp/venv/bin/pip install flask gunicorn

# ==========================================
# 6. Create Flask application
# ==========================================

cat > /opt/webapp/app.py <<'PYTHON'

from flask import Flask, request, redirect, render_template_string
import sqlite3
import socket

app = Flask(__name__)

DATABASE = "/opt/webapp/app.db"


def get_db():
    connection = sqlite3.connect(DATABASE)
    connection.row_factory = sqlite3.Row
    return connection


def init_db():
    db = get_db()

    db.execute("""
        CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL
        )
    """)

    db.commit()
    db.close()


HTML = """
<!DOCTYPE html>
<html>

<head>

    <title>Cravita Application</title>

    <style>

        body {
            font-family: Arial, sans-serif;
            background: #f4f6f8;
            margin: 0;
            padding: 40px;
        }

        .container {
            max-width: 800px;
            margin: auto;
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }

        h1 {
            color: #222;
        }

        .server {
            background: #eef2f7;
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 25px;
        }

        input {
            padding: 10px;
            width: 60%;
        }

        button {
            padding: 10px 20px;
            cursor: pointer;
        }

        table {
            width: 100%;
            margin-top: 20px;
            border-collapse: collapse;
        }

        th, td {
            padding: 10px;
            border-bottom: 1px solid #ddd;
            text-align: left;
        }

    </style>

</head>

<body>

<div class="container">

    <h1>Cravita Web Application</h1>

    <div class="server">

        <strong>Application Server:</strong>
        {{ hostname }}

        <br><br>

        <strong>Application:</strong>
        Flask + Gunicorn

        <br><br>

        <strong>Database:</strong>
        SQLite

    </div>

    <h2>Add User</h2>

    <form method="POST" action="/add">

        <input
            type="text"
            name="name"
            placeholder="Enter user name"
            required
        >

        <button type="submit">
            Add User
        </button>

    </form>

    <h2>Users</h2>

    <table>

        <tr>
            <th>ID</th>
            <th>Name</th>
        </tr>

        {% for user in users %}

        <tr>
            <td>{{ user["id"] }}</td>
            <td>{{ user["name"] }}</td>
        </tr>

        {% endfor %}

    </table>

</div>

</body>

</html>
"""


@app.route("/")
def index():

    db = get_db()

    users = db.execute(
        "SELECT * FROM users ORDER BY id DESC"
    ).fetchall()

    db.close()

    return render_template_string(
        HTML,
        users=users,
        hostname=socket.gethostname()
    )


@app.route("/add", methods=["POST"])
def add_user():

    name = request.form["name"]

    db = get_db()

    db.execute(
        "INSERT INTO users (name) VALUES (?)",
        (name,)
    )

    db.commit()
    db.close()

    return redirect("/")


@app.route("/health")
def health():

    return "Application is healthy"


init_db()


if __name__ == "__main__":

    app.run(
        host="127.0.0.1",
        port=5000
    )

PYTHON

# ==========================================
# 7. Set application ownership
# ==========================================

chown -R webapp:webapp /opt/webapp

# ==========================================
# 8. Create systemd service
# ==========================================

cat > /etc/systemd/system/webapp.service <<'SERVICE'

[Unit]
Description=Cravita Flask Application
After=network.target

[Service]

User=webapp
Group=webapp

WorkingDirectory=/opt/webapp

ExecStart=/opt/webapp/venv/bin/gunicorn \
    --workers 2 \
    --bind 127.0.0.1:5000 \
    app:app

Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target

SERVICE

# ==========================================
# 9. Start application
# ==========================================

systemctl daemon-reload

systemctl enable webapp

systemctl start webapp

# ==========================================
# 10. Configure Nginx
# ==========================================

cat > /etc/nginx/sites-available/default <<'NGINX'

server {

    listen 80 default_server;
    listen [::]:80 default_server;

    server_name _;

    location / {

        proxy_pass http://127.0.0.1:5000;

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

    }

}

NGINX

# ==========================================
# 11. Validate Nginx configuration
# ==========================================

nginx -t

# ==========================================
# 12. Start Nginx
# ==========================================

systemctl enable nginx

systemctl restart nginx

# ==========================================
# 13. Final status
# ==========================================

systemctl status nginx --no-pager
systemctl status webapp --no-pager

echo "=========================================="
echo "Cravita application deployment completed"
echo "=========================================="
EOF

  tags = {
    Name = "${var.project_name}-blue-ec2-instance"
  }
}
/*
resource "aws_instance" "green_ec2_instance" {
    ami                    = var.ami_id
    instance_type          = var.instance_type
    key_name               = var.key_name
    subnet_id              = var.public_subnet_2_id
    vpc_security_group_ids = [var.green_ec2_sg_id]
    
    user_data = <<-EOF
#!/bin/bash

set -e

# ==========================================
# 1. Update and upgrade Ubuntu
# ==========================================

export DEBIAN_FRONTEND=noninteractive

apt-get update -y
apt-get upgrade -y

# ==========================================
# 2. Install required packages
# ==========================================

apt-get install -y \
    nginx \
    python3 \
    python3-pip \
    python3-venv \
    sqlite3 \
    curl

# ==========================================
# 3. Create application user
# ==========================================

useradd --system --create-home --shell /usr/sbin/nologin webapp || true

# ==========================================
# 4. Create application directory
# ==========================================

mkdir -p /opt/webapp
chown -R webapp:webapp /opt/webapp

# ==========================================
# 5. Create Python virtual environment
# ==========================================

python3 -m venv /opt/webapp/venv

/opt/webapp/venv/bin/pip install --upgrade pip
/opt/webapp/venv/bin/pip install flask gunicorn

# ==========================================
# 6. Create Flask application
# ==========================================

cat > /opt/webapp/app.py <<'PYTHON'

from flask import Flask, request, redirect, render_template_string
import sqlite3
import socket

app = Flask(__name__)

DATABASE = "/opt/webapp/app.db"


def get_db():
    connection = sqlite3.connect(DATABASE)
    connection.row_factory = sqlite3.Row
    return connection


def init_db():
    db = get_db()

    db.execute("""
        CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL
        )
    """)

    db.commit()
    db.close()


HTML = """
<!DOCTYPE html>
<html>

<head>

    <title>Cravita Application</title>

    <style>

        body {
            font-family: Arial, sans-serif;
            background: #f4f6f8;
            margin: 0;
            padding: 40px;
        }

        .container {
            max-width: 800px;
            margin: auto;
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }

        h1 {
            color: #222;
        }

        .server {
            background: #eef2f7;
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 25px;
        }

        input {
            padding: 10px;
            width: 60%;
        }

        button {
            padding: 10px 20px;
            cursor: pointer;
        }

        table {
            width: 100%;
            margin-top: 20px;
            border-collapse: collapse;
        }

        th, td {
            padding: 10px;
            border-bottom: 1px solid #ddd;
            text-align: left;
        }

    </style>

</head>

<body>

<div class="container">

    <h1>Cravita Web Application</h1>

    <div class="server">

        <strong>Application Server:</strong>
        {{ hostname }}

        <br><br>

        <strong>Application:</strong>
        Flask + Gunicorn

        <br><br>

        <strong>Database:</strong>
        SQLite

    </div>

    <h2>Add User</h2>

    <form method="POST" action="/add">

        <input
            type="text"
            name="name"
            placeholder="Enter user name"
            required
        >

        <button type="submit">
            Add User
        </button>

    </form>

    <h2>Users</h2>

    <table>

        <tr>
            <th>ID</th>
            <th>Name</th>
        </tr>

        {% for user in users %}

        <tr>
            <td>{{ user["id"] }}</td>
            <td>{{ user["name"] }}</td>
        </tr>

        {% endfor %}

    </table>

</div>

</body>

</html>
"""


@app.route("/")
def index():

    db = get_db()

    users = db.execute(
        "SELECT * FROM users ORDER BY id DESC"
    ).fetchall()

    db.close()

    return render_template_string(
        HTML,
        users=users,
        hostname=socket.gethostname()
    )


@app.route("/add", methods=["POST"])
def add_user():

    name = request.form["name"]

    db = get_db()

    db.execute(
        "INSERT INTO users (name) VALUES (?)",
        (name,)
    )

    db.commit()
    db.close()

    return redirect("/")


@app.route("/health")
def health():

    return "Application is healthy"


init_db()


if __name__ == "__main__":

    app.run(
        host="127.0.0.1",
        port=5000
    )

PYTHON

# ==========================================
# 7. Set application ownership
# ==========================================

chown -R webapp:webapp /opt/webapp

# ==========================================
# 8. Create systemd service
# ==========================================

cat > /etc/systemd/system/webapp.service <<'SERVICE'

[Unit]
Description=Cravita Flask Application
After=network.target

[Service]

User=webapp
Group=webapp

WorkingDirectory=/opt/webapp

ExecStart=/opt/webapp/venv/bin/gunicorn \
    --workers 2 \
    --bind 127.0.0.1:5000 \
    app:app

Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target

SERVICE

# ==========================================
# 9. Start application
# ==========================================

systemctl daemon-reload

systemctl enable webapp

systemctl start webapp

# ==========================================
# 10. Configure Nginx
# ==========================================

cat > /etc/nginx/sites-available/default <<'NGINX'

server {

    listen 80 default_server;
    listen [::]:80 default_server;

    server_name _;

    location / {

        proxy_pass http://127.0.0.1:5000;

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

    }

}

NGINX

# ==========================================
# 11. Validate Nginx configuration
# ==========================================

nginx -t

# ==========================================
# 12. Start Nginx
# ==========================================

systemctl enable nginx

systemctl restart nginx

# ==========================================
# 13. Final status
# ==========================================

systemctl status nginx --no-pager
systemctl status webapp --no-pager

echo "=========================================="
echo "Cravita application deployment completed"
echo "=========================================="
EOF

    tags = {
        Name = "${var.project_name}-green-ec2-instance"
    }
}*/