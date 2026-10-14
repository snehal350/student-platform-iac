#!/usr/bin/env bash
set -u
cd "$(dirname "$0")/.."
[ -f ~/ansible-venv/bin/activate ] && source ~/ansible-venv/bin/activate
IP=$(terraform -chdir=terraform output -raw app_server_public_ip)
KEY=~/.ssh/student-aws-key
INV=ansible/inventory/hosts.ini

echo "=== Gate 1: Network & OS ==="
timeout 5 bash -c "</dev/tcp/$IP/22" && echo "SSH port 22 OPEN"
ssh -i $KEY -o StrictHostKeyChecking=no ubuntu@$IP uptime

echo "=== Gate 2: Daemons & Ports ==="
ansible student_servers -i $INV -b -m ansible.builtin.systemd -a "name=docker state=started"
ansible student_servers -i $INV -b -m ansible.builtin.systemd -a "name=nginx state=started"
ssh -i $KEY ubuntu@$IP "sudo ss -tlnp | grep -E ':80 |:8080 '"

echo "=== Gate 3: App Container ==="
ssh -i $KEY ubuntu@$IP "sudo docker ps --filter name=student-app --format '{{.Names}} -> {{.Status}}'"

echo "=== Gate 4: API Smoke Tests ==="
curl -s -f http://$IP/api/health | jq .
curl -s -f http://$IP/api/students | jq .
curl -s -X POST http://$IP/api/marks -H "Content-Type: application/json" \
     -d '{"student_id":1,"subject":"DevOps","marks":88}' | jq .
echo "=== DONE ==="
