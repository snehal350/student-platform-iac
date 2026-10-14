# Student Record Platform: Infrastructure Automation on AWS

Mini Project 3 (Unit 4: DevOps Automation)

## What this project does
- **Terraform** creates the AWS infrastructure: VPC, public subnet, internet gateway, route table, security group, EC2 server, S3 backup bucket.
- **Ansible** configures the server: base packages, Docker, Nginx reverse proxy, and deploys the Student Record Flask app.
- The app runs in Docker on port 8080, and Nginx forwards port 80 to it.

## API endpoints
- `GET /api/health`
- `GET /api/students`
- `POST /api/marks`

## Folder structure
- `app/` Flask app and Dockerfile
- `terraform/` infrastructure code
- `ansible/` playbook and roles (common, docker, nginx, student_app)
- `scripts/setup-controller.sh` installs Terraform and Ansible on the control node
- `scripts/validate.sh` 4-gate validation script
- `docs/` validation log and screenshots

## How to run (on the AWS control node)
1. `bash scripts/setup-controller.sh`
2. `cd terraform && terraform init && terraform apply`
3. `cd ../ansible && ansible-playbook site.yml`
4. `bash scripts/validate.sh`
5. `terraform destroy` when finished

## Author
Snehal Patange
