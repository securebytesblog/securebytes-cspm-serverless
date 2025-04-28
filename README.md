
# 🚀 SecureBytes - Serverless Real-Time CSPM Dashboard

Welcome to the **SecureBytes Serverless CSPM Dashboard** project!  
This project provides a **fully serverless, real-time Cloud Security Posture Management (CSPM)** system using **AWS Lambda**, **DynamoDB**, **API Gateway**, and **Grafana**.

---

## 📍 Architecture

```
Lambda CSPM Scanner
   ↓
DynamoDB Table (Findings Storage)
   ↓
Lambda API (Findings Query)
   ↓
API Gateway
   ↓
Grafana Dashboard (JSON API Plugin)
```

---

## 📦 What's Included

- **Terraform** scripts for automated infrastructure setup:
  - DynamoDB Table
  - Lambda Functions
  - API Gateway
  - IAM Roles and Policies
- **Lambda Functions**:
  - Save CSPM findings
  - Query findings with advanced filters
- **Grafana Dashboard Template**:
  - JSON template ready to import
- **Full Deployment Guide**

---

## ✨ Features

- Real-time compliance findings
- REST API querying DynamoDB
- Filter findings by **severity**, **resource**, **time range**
- Fully serverless (no servers to maintain)
- Grafana-ready dashboard for instant visualization

---

## 🛠️ Deployment Steps

### 1. Prerequisites

- AWS account with permissions (IAM, DynamoDB, Lambda, API Gateway)
- AWS CLI installed and configured
- Terraform installed
- Grafana (self-hosted or Grafana Cloud)

### 2. Clone This Repository

```bash
git clone https://github.com/YOUR-USERNAME/securebytes-cspm-serverless.git
cd securebytes-cspm-serverless/terraform
```

### 3. Initialize and Apply Terraform

```bash
terraform init
terraform apply
```
_**Terraform will output the API Gateway URL**_

### 4. Deploy Lambda (Optional)

If needed, upload `lambda_query_findings.zip` manually to AWS Lambda.

### 5. Set Up Grafana Data Source

- Install **JSON API Plugin**:
  ```bash
  grafana-cli plugins install marcusolsson-json-datasource
  sudo systemctl restart grafana-server
  ```
- Create new **JSON API data source** with:
  - URL: `https://<your-api-id>.execute-api.<region>.amazonaws.com`
- Test connection.

### 6. Import Grafana Dashboard

- Import `grafana/cspm_dashboard.json` provided.
- Select your JSON API datasource when importing.

---

## 🌐 API Usage

You can query the findings using these parameters:

| Parameter | Purpose | Example |
|:----------|:--------|:--------|
| `severity` | Filter by severity (`High`, `Medium`, `Low`) | `/findings?severity=High` |
| `resource_id` | Filter by specific resource | `/findings?resource_id=my-s3-bucket` |
| `hours` | Retrieve findings in the last X hours | `/findings?hours=12` |

✅ Supports combining parameters too!

---

## 📜 License

This project is licensed under the [MIT License](LICENSE).

---

## ✉️ Stay Connected

- 🔥 Read more cybersecurity articles on [SecureBytesBlog.com](https://securebytesblog.com/)
- ⭐ Star this repository if you found it useful!

---

# 🚀 Let's build secure cloud environments together!
