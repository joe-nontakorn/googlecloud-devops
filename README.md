# 🚀 Google Cloud DevOps: Full Stack Infrastructure & CI/CD with K3s

โปรเจกต์นี้เป็นการสร้างระบบ Infrastructure แบบครบวงจร Deploy แอปพลิเคชัน Vue.js ลงบน Kubernetes (K3s) บน Google Cloud Platform (GCE)

---

## 🏗️ Architecture Overview

```
┌──────────────────────────────────────────────────────────────┐
│  Google Cloud Platform (GCE)                                 │
│  Instance: 34.66.183.14                                      │
│                                                              │
│   ┌──────────┐   ┌──────────┐   ┌──────────────────────┐    │
│   │  Docker   │   │   K3s    │   │  GitHub Self-hosted  │    │
│   │  Engine   │   │ (latest) │   │  Runner              │    │
│   └──────────┘   └────┬─────┘   └──────────────────────┘    │
│                       │                                      │
│          ┌────────────┼────────────┐                         │
│          │            │            │                          │
│     ┌────▼───┐   ┌────▼───┐   ┌───▼──────┐                  │
│     │Traefik │   │Vue App │   │Dashboard │                  │
│     │Ingress │   │(Nginx) │   │  (GUI)   │                  │
│     │ :80    │   │ :80    │   │ :30001   │                  │
│     └────────┘   └────────┘   └──────────┘                  │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

### Pipeline Flow

```
git push → GitHub Actions → Build Docker Image → Push to GHCR
                ↓
       Self-hosted Runner (บน GCE Instance)
                ↓
       kubectl apply → K3s Deploy → Rollout Status
                ↓
       🌐 http://34.66.183.14
```

---

## 📋 Prerequisites

| ซอฟต์แวร์    | เวอร์ชันขั้นต่ำ | หมายเหตุ                          |
|--------------|-----------------|-----------------------------------|
| Docker       | 20.10+          | สำหรับ Build Image ในเครื่อง       |
| Terraform    | 1.0+            | สำหรับสร้าง Infrastructure (GCP)   |
| Ansible      | 2.9+ (via WSL)  | สำหรับจัดการ Configuration         |
| kubectl      | 1.26+           | สำหรับจัดการ Kubernetes            |
| Node.js      | 22+             | สำหรับ Development (Vue.js)        |
| Git          | 2.30+           | สำหรับ Version Control             |
| GCP Account  | -               | พร้อม Service Account Key          |

---

## 📁 Directory Structure

```
googlecloud-devops/
├── .github/
│   └── workflows/
│       └── deploy.yml          # CI/CD Pipeline (GitHub Actions)
├── Ansible/
│   ├── inventory.ini           # GCP Server (34.66.183.14)
│   ├── playbook.yml            # ติดตั้ง Docker + K3s
│   ├── dashboard.yml           # ติดตั้ง Kubernetes Dashboard
│   └── runner.yml              # ติดตั้ง GitHub Self-hosted Runner
├── k8s/
│   └── deployment.yml          # K8s Deployment + Service + Ingress
├── terraform/
│   ├── main.tf                 # สร้าง GCE Instance + Firewall Rules
│   ├── variables.tf            # ตัวแปรสำหรับ Terraform
│   ├── outputs.tf              # ค่าที่แสดงหลังจากสร้างเสร็จ
│   └── terraform.tfvars.example # ตัวอย่างไฟล์ตัวแปร
├── src/                        # Vue.js Source Code
├── index.html                  # HTML Entry Point
├── Dockerfile                  # Multi-stage Build (Node → Nginx)
├── nginx.conf                  # Nginx Configuration
├── package.json                # Dependencies และ Scripts
├── vite.config.ts              # Vite Configuration
├── .dockerignore               # ไฟล์ที่ไม่ต้อง Copy เข้า Image
├── .gitignore                  # ไฟล์ที่ไม่ต้อง Commit
└── README.md                   # ไฟล์ที่คุณกำลังอ่านอยู่นี้
```

---

## 🛠️ How to Use

### Step 1: สร้าง Infrastructure ด้วย Terraform

```bash
cd terraform

# สร้างไฟล์ตัวแปร
cp terraform.tfvars.example terraform.tfvars
# แก้ไข project_id ให้ตรงกับ GCP Project ของคุณ

terraform init
terraform plan
terraform apply
```

> ⚠️ ถ้ามี Instance อยู่แล้วที่ 34.xxx.xxx.xx ให้ใช้ `terraform import` แทน:
> ```bash
> terraform import google_compute_instance.gcp_server <project>/<zone>/<instance-name>
> ```

### Step 2: ติดตั้งระบบด้วย Ansible (รันผ่าน WSL)

```bash
cd Ansible

# ทดสอบ SSH Connection ก่อน
ansible -i inventory.ini servers -m ping

# ติดตั้ง Docker + K3s บน GCE Instance
ansible-playbook -i inventory.ini playbook.yml

# ติดตั้ง Kubernetes Dashboard
ansible-playbook -i inventory.ini dashboard.yml

# ติดตั้ง GitHub Self-hosted Runner
# ⚠️ ต้องแก้ runner_token ใน runner.yml ก่อนรัน
ansible-playbook -i inventory.ini runner.yml
```

### Step 3: สร้าง GHCR Secret ใน K8s (ครั้งแรก)

```bash
# SSH เข้า GCE Instance
ssh -i ~/.ssh/gcp_key nontakorn_kha@34.66.183.14

# สร้าง Secret สำหรับดึง Image จาก GHCR
kubectl create secret docker-registry ghcr-secret \
  --docker-server=ghcr.io \
  --docker-username=YOUR_GITHUB_USERNAME \
  --docker-password=YOUR_GITHUB_PAT
```

### Step 4: Push โค้ดเพื่อ Trigger CI/CD

```bash
git add .
git commit -m "deploy: update application"
git push origin master
```

GitHub Actions จะทำงานอัตโนมัติ:
1. **Job: build-and-push** — Build Docker Image (Vue.js + Nginx) แล้ว Push ไปยัง GHCR
2. **Job: deploy** — ใช้ Self-hosted Runner สั่ง `kubectl apply` และรอ rollout สำเร็จ

---

## 🌐 Access Points

| Service              | URL                           | หมายเหตุ                           |
|----------------------|-------------------------------|------------------------------------|
| **แอปพลิเคชัน**      | http://34.xxx.xxx.xx           | ผ่าน Traefik Ingress               |
| **K8s Dashboard**    | https://34.xxx.xxx.xx:30001    | ต้องใช้ Token เพื่อ Login           |
| **K3s API Server**   | https://34.xxx.xxx.xx:6443     | สำหรับ kubectl remote              |
| **SSH**              | ssh -i ~/.ssh/gcp_key nontakorn_kha@34.xxx.xxx.xx.14 | SSH Access |

---

## 🔑 Useful Commands

### จัดการ Kubernetes (ผ่าน SSH)

```bash
# SSH เข้า Instance
ssh -i ~/.ssh/gcp_key nontakorn_kha@34.66.183.14

# ดู Pod ทั้งหมด
kubectl get pods -A

# ดู Service ทั้งหมด
kubectl get svc -A

# ดู Log ของแอป
kubectl logs -f deployment/vue-app

# Restart แอป
kubectl rollout restart deployment vue-app
```

### ใช้ kubectl จากเครื่อง Windows โดยตรง

```powershell
# ดึง Kubeconfig ออกมา
scp -i ~/.ssh/gcp_key nontakorn_kha@34.66.183.14:/etc/rancher/k3s/k3s.yaml ./k3s_config.yaml

# แก้ server address ให้ชี้ไปที่ External IP
(Get-Content k3s_config.yaml) -replace '127.0.0.1', '34.34.xxx.xxx.xx' | Set-Content k3s_config.yaml

# ตั้งค่า KUBECONFIG
$env:KUBECONFIG=".\k3s_config.yaml"

# ใช้คำสั่ง kubectl ได้ตามปกติ
kubectl get pods -A
```

### จัดการ Dashboard

```bash
# สร้าง Token สำหรับ Login
kubectl -n kubernetes-dashboard create token admin-user
```

---

## 🐛 Troubleshooting

### Ansible ขึ้น Permission denied
**สาเหตุ:** SSH key ไม่ถูกต้อง หรือ user ไม่ตรง
**วิธีแก้:**
```bash
# ทดสอบ SSH ก่อน
ssh -i ~/.ssh/gcp_key nontakorn_kha@34.66.183.14

# ตรวจสอบ key permission
chmod 600 ~/.ssh/gcp_key
```

### แอปแสดง 404 page not found
**สาเหตุ:** Ingress ยังไม่ได้ Deploy หรือ Pod ยังไม่พร้อม
**วิธีแก้:**
```bash
kubectl get ingress
kubectl get pods -l app=vue-app
kubectl describe ingress vue-app-ingress
```

### Image Pull Error (ErrImagePull)
**สาเหตุ:** K3s ดึง Image จาก GHCR ไม่ได้ (private repo)
**วิธีแก้:**
```bash
# สร้าง/อัพเดท GHCR Secret
kubectl delete secret ghcr-secret --ignore-not-found
kubectl create secret docker-registry ghcr-secret \
  --docker-server=ghcr.io \
  --docker-username=YOUR_GITHUB_USERNAME \
  --docker-password=YOUR_GITHUB_PAT
```

---

## 🌟 Tech Stack

| เครื่องมือ          | บทบาท                                  |
|--------------------|----------------------------------------|
| **Vue.js 3**       | Frontend Framework (SPA)               |
| **Vite**           | Build Tool สำหรับ Vue.js               |
| **Nginx**          | Web Server สำหรับ Serve Static Files   |
| **Docker**         | Containerization (Multi-stage Build)   |
| **K3s**            | Lightweight Kubernetes Orchestrator    |
| **Terraform**      | Infrastructure as Code (GCP)           |
| **Ansible**        | Configuration Management & Automation  |
| **GitHub Actions** | CI/CD Pipeline                         |
| **Traefik**        | Ingress Controller (มาพร้อม K3s)      |
| **GHCR**           | Container Registry สำหรับเก็บ Image    |
| **Google Cloud**   | Cloud Platform (GCE)                   |

---

## 📋 GitHub Secrets ที่ต้องตั้งค่า

ไปที่ GitHub Repo → Settings → Secrets and variables → Actions:

| Secret Name   | คำอธิบาย                                     |
|---------------|----------------------------------------------|
| `GHCR_PAT`    | GitHub Personal Access Token (read:packages) |

> `GITHUB_TOKEN` จะถูกสร้างให้อัตโนมัติโดย GitHub Actions

---

*Created with ❤️ for DevOps Learning on Google Cloud*
