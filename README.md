<div align="center">

<h1> Flask App CI/CD Pipeline</h1>

<p><strong>Jenkins · AWS EC2 Dynamic Agents · Docker · SonarQube · GitHub Actions</strong></p>

[![Build Pipeline](https://img.shields.io/badge/Build%20Pipeline-Passing-brightgreen?style=flat-square&logo=jenkins)](https://github.com/Sumitkalamkar/jenkins_cicd)
[![Jenkins](https://img.shields.io/badge/Jenkins-2.555.1-red?style=flat-square&logo=jenkins)](https://www.jenkins.io/)
[![Docker](https://img.shields.io/badge/Docker-Containerized-2496ED?style=flat-square&logo=docker)](https://www.docker.com/)
[![AWS](https://img.shields.io/badge/AWS-EC2%20Dynamic%20Agents-FF9900?style=flat-square&logo=amazonaws)](https://aws.amazon.com/)
[![Python](https://img.shields.io/badge/Python-Flask-3776AB?style=flat-square&logo=python)](https://flask.palletsprojects.com/)
[![SonarQube](https://img.shields.io/badge/SonarQube-Code%20Quality-4E9BCD?style=flat-square&logo=sonarqube)](https://www.sonarqube.org/)
[![GitHub Actions](https://img.shields.io/badge/GitHub%20Actions-CI-181717?style=flat-square&logo=githubactions)](https://github.com/features/actions)

<p>A complete, production-style DevOps CI/CD project with dynamic AWS cloud infrastructure.<br/>Built as part of the <strong>GeeksForGeeks DevOps Course</strong>.</p>

</div>

---

## Overview

This project implements a **full CI/CD pipeline** for a Python Flask application, covering everything from automated testing on push to containerized deployment on dynamically provisioned AWS EC2 instances.

**Key highlights:**

- Jenkins automatically provisions fresh EC2 agents per build — no static build servers
- Every Git push triggers tests via GitHub Actions before Jenkins picks up the workload
- SonarQube gates code quality before Docker images are built
- The entire pipeline is defined as code (`Jenkinsfile`)

---

## Architecture

```
GitHub Push
    │
    ▼
┌─────────────────────────┐
│     GitHub Actions      │  ← Run unit tests on every push
└────────────┬────────────┘
             │
             ▼
┌─────────────────────────┐
│        Jenkins          │  ← Orchestrates the full pipeline
└────────────┬────────────┘
             │
             ▼
┌─────────────────────────┐
│  AWS Dynamic EC2 Agent  │  ← Auto-provisioned, SSH-connected, auto-terminated
└────────────┬────────────┘
             │
             ▼
┌────────────────────────────────────────┐
│  Test → SonarQube → Docker Build       │
│            → Deploy Flask App          │
└────────────────────────────────────────┘
```

The pipeline runs **3 chained Freestyle Jobs**, visualized via the Build Pipeline Plugin:

| # | Job | Action | Duration |
|---|-----|--------|---------|
| 1 | `job1-testapp` | Install deps & run Pytest | ~2.2 sec |
| 2 | `job2-docker-build` | Build Docker image | ~8.4 sec |
| 3 | `job3-deployapp` | Run Flask container | ~0.77 sec |

---

## Dynamic AWS EC2 Agents

> **The standout feature of this project.**

Instead of running builds on the Jenkins controller:

1. Jenkins automatically **launches a fresh EC2 instance** when a build is queued
2. The instance is SSH-connected and registered as a build agent
3. The pipeline executes on the ephemeral instance
4. The instance **auto-terminates** after idle timeout

**Confirmed execution on a real AWS EC2 instance:**

```
Running on EC2 (aws-dynamic-agents) - Dynamic EC2 Worker
Hostname: ip-172-31-2-85.ap-south-1.compute.internal
```

### EC2 Agent Configuration

| Setting | Value |
|--------|-------|
| AMI | Amazon Linux 2023 |
| Connection | SSH |
| Java | Auto-installed |
| Idle Timeout | Auto-terminate |
| Scheduling | Label-based (`linux`) |

---

## Project Structure

```
jenkins_cicd/
├── app.py                      # Flask web application
├── test_app.py                 # Pytest unit tests
├── requirements.txt            # Python dependencies
├── Dockerfile                  # Container image definition
├── Jenkinsfile                 # Pipeline-as-code
├── sonar-project.properties    # SonarQube config
└── .github/
    └── workflows/
        └── ci.yml              # GitHub Actions workflow
```

---

## Getting Started

### Prerequisites

- Jenkins (with Build Pipeline & Git plugins)
- Docker installed on the Jenkins agent
- Python 3.x
- AWS account (for dynamic EC2 agents)

### 1. Clone the Repository

```bash
git clone https://github.com/Sumitkalamkar/jenkins_cicd.git
cd jenkins_cicd
```

### 2. Run Locally

```bash
# Install dependencies
pip install -r requirements.txt

# Run tests
pytest test_app.py

# Build and run Docker image
docker build -t flask-cicd-app .
docker run -p 5000:5000 flask-cicd-app
```

### 3. Start Jenkins via Docker

```bash
docker run -d \
  --name jenkins \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  jenkins/jenkins:lts
```

### 4. Configure Jenkins Jobs

**`job1-testapp`**
- Source: Git → this repo
- Build Step: `pip install -r requirements.txt && pytest test_app.py`
- Post-build: Trigger `job2-docker-build` if stable

**`job2-docker-build`**
- Build Step: `docker build -t flask-cicd-app .`
- Post-build: Trigger `job3-deployapp` if stable

**`job3-deployapp`**
- Build Step: `docker run -d -p 5000:5000 flask-cicd-app`

### 5. Create Build Pipeline View

1. Click **+ New View** → choose **Build Pipeline View**
2. Set `job1-testapp` as the initial job
3. Watch the 3-stage pipeline execute end-to-end

---

## Configuration Files

### Jenkinsfile (Pipeline-as-Code)

```groovy
pipeline {
    agent { label 'linux' }

    stages {
        stage('Test') {
            steps {
                sh 'pytest test_app.py'
            }
        }
        stage('SonarQube Analysis') {
            steps {
                sh 'sonar-scanner'
            }
        }
        stage('Docker Build') {
            steps {
                sh 'docker build -t flask-cicd-app .'
            }
        }
        stage('Deploy') {
            steps {
                sh 'docker run -d -p 5000:5000 flask-cicd-app'
            }
        }
    }
}
```

### GitHub Actions Workflow (`.github/workflows/ci.yml`)

```yaml
name: Flask CI

on:
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
      - run: pip install -r requirements.txt
      - run: pytest
```

### SonarQube (`sonar-project.properties`)

```properties
sonar.projectKey=flask-cicd
sonar.projectName=Flask CI/CD App
sonar.sources=.
sonar.python.coverage.reportPaths=coverage.xml
```

---

## Tech Stack

| Technology | Role |
|-----------|------|
| Jenkins 2.555.1 | CI/CD orchestration |
| AWS EC2 | Dynamic build agents |
| Docker | Containerization |
| Python / Flask | Web application |
| Pytest | Unit testing |
| SonarQube | Static code analysis & quality gates |
| GitHub Actions | Pre-Jenkins CI on push |
| Build Pipeline Plugin | Visual pipeline view |

---

## What I Learned

Built while completing the full **GeeksForGeeks DevOps Course**. Each tool was learned completely — from setup to production integration.

---

### Jenkins

#### Freestyle Jobs

- Created Freestyle Jobs from scratch in the Jenkins UI
- Configured Git source code management inside each job
- Added shell build steps (`pip install`, `pytest`, `docker build`, `docker run`)
- Understood the full build lifecycle — trigger → checkout → build → post-build
- Chained 3 jobs using **post-build triggers** so job1 → job2 → job3 run in sequence only on stable builds
- Used the **Build Pipeline Plugin** to get a visual view of the entire chained flow

#### Pipeline-as-Code (Jenkinsfile)

- Wrote a `Jenkinsfile` using **Declarative Pipeline** syntax (`pipeline {}` block)
- Defined stages: `Test`, `SonarQube Analysis`, `Docker Build`, `Deploy`
- Understood the difference between Freestyle Jobs (UI-configured) vs Pipeline-as-Code (version-controlled, repeatable)
- Learned `agent`, `stages`, `steps`, and `post` blocks

#### Static Agent — Docker Container

- Ran a Docker container as a **permanently registered Jenkins agent**
- Connected the container to Jenkins master via SSH or JNLP
- Assigned a label and ran builds inside the container
- Understood the limitation: container always has to be running even when no builds are queued
- Good for local/dev environments but not scalable for production workloads

#### Static Agent — AWS EC2 Instance

- Manually launched an EC2 instance and registered it as a **permanent Jenkins node**
- Connected via SSH, assigned a build label (`linux`), configured the remote root directory
- Ran full pipeline builds on the fixed EC2 node
- Understood the drawbacks of static EC2 agents:
  - Instance runs 24/7 — paying even when no builds are happening
  - No automatic scaling — one agent handles one build at a time
  - Any failure on the node requires manual intervention to recover

#### Dynamic Agent — Docker Container

- Configured Jenkins to spin up a **fresh Docker container as a build agent on demand**
- Container is created when a build starts and destroyed automatically after it finishes
- Each build gets a clean, isolated environment — no leftover state from previous runs
- Learned how to define the agent image and workspace inside the `Jenkinsfile`:
  ```groovy
  agent {
      docker { image 'python:3.11' }
  }
  ```
- Understood the advantage: no idle container costs, perfectly reproducible builds

#### Dynamic Agent — AWS EC2 Instance

- Installed and configured the **AWS EC2 Plugin** in Jenkins
- Jenkins auto-launches a **brand new EC2 instance** each time a build is queued
- Instance connects via SSH, Java is auto-installed, build executes, then instance **auto-terminates** after idle timeout
- Configured: AMI (Amazon Linux 2023), instance type, SSH credentials, label (`linux`), idle timeout
- Confirmed real dynamic execution on AWS:
  ```
  Running on EC2 (aws-dynamic-agents) - Dynamic EC2 Worker
  Hostname: ip-172-31-2-85.ap-south-1.compute.internal
  ```
- Understood the full comparison across all four approaches:

| | Static | Dynamic |
|---|---|---|
| **Docker** | Container always running | Container created & destroyed per build |
| **EC2** | Instance always running (costly) | Instance auto-provisioned & terminated per build |

---

### SonarQube

#### Setup & Configuration

- Deployed SonarQube server locally and accessed the dashboard
- Created a project and generated an authentication token
- Configured `sonar-project.properties` with:
  ```properties
  sonar.projectKey=flask-cicd
  sonar.projectName=Flask CI/CD App
  sonar.sources=.
  sonar.python.coverage.reportPaths=coverage.xml
  ```
- Installed `sonar-scanner` CLI on the build agent
- Added SonarQube server URL and token to Jenkins credentials

#### Code Analysis & Quality Gates

- Integrated `sonar-scanner` as a dedicated stage in the `Jenkinsfile`
- Learned the four analysis dimensions SonarQube checks:
  - **Bugs** — logical errors that break functionality at runtime
  - **Code Smells** — maintainability and readability issues
  - **Security Vulnerabilities** — unsafe patterns (hardcoded secrets, injection risks)
  - **Test Coverage** — percentage of code exercised by Pytest, reported via `coverage.xml`
- Understood **Quality Gates**: if code doesn't pass the threshold, the pipeline fails before Docker build even starts — bad code never reaches deployment

---

### GitHub Actions

#### Workflow Setup

- Created `.github/workflows/ci.yml` from scratch
- Learned the YAML structure: `on`, `jobs`, `runs-on`, `steps`
- Configured push trigger on the `main` branch
- Used a free **Ubuntu runner** (`ubuntu-latest`) provided by GitHub

#### CI Pipeline

- Set up all steps: checkout → Python setup → dependency install → test run
- Used official actions: `actions/checkout@v4`, `actions/setup-python@v5`
- Automated Pytest execution on every push — no manual trigger needed
- Understood the role split between both CI systems:
  - **GitHub Actions** = lightweight, fast pre-check that runs on every push for free
  - **Jenkins** = full pipeline with AWS cloud agents, SonarQube, Docker build, and deployment

---

## Screenshots

### Jenkins Build Pipeline View
<!-- Take a screenshot of your Jenkins Build Pipeline Plugin view showing all 3 jobs -->
![Jenkins Build Pipeline](jenkins-pipe.png)

### Jenkins Job Console Output
<!-- Take a screenshot of any job's console output showing a successful build -->
![Jenkins Console Output](assets/screenshots/jenkins-console-output.png)

### Dynamic EC2 Agent — Proof of Execution
<!-- Take a screenshot of Jenkins console showing "Running on EC2 (aws-dynamic-agents)" -->
![Dynamic EC2 Agent](assets/screenshots/ec2-dynamic-agent.png)

### SonarQube Dashboard
<!-- Take a screenshot of your SonarQube project dashboard showing analysis results -->
![SonarQube Dashboard](assets/screenshots/sonarqube-dashboard.png)

### GitHub Actions — CI Passing
<!-- Take a screenshot of your GitHub Actions workflow showing green passing status -->
![GitHub Actions](assets/screenshots/github-actions-passing.png)

### Flask App Running
<!-- Take a screenshot of the Flask app running in your browser on port 5000 -->
![Flask App](assets/screenshots/flask-app-running.png)

> **To add your screenshots:**
> 1. Create a folder `assets/screenshots/` in this repo
> 2. Upload each screenshot with the exact filename shown above
> 3. Images will automatically render here on GitHub

---

## Roadmap

- [ ] Kubernetes deployment via Helm charts
- [ ] Terraform for EC2 agent infrastructure-as-code
- [ ] DockerHub image push on successful build
- [ ] Prometheus + Grafana pipeline monitoring
- [ ] Nginx reverse proxy for deployed app
- [ ] Multi-branch pipelines for feature branch isolation

---

## Author

**Sumit Pandurang Kalamkar**
[GitHub →](https://github.com/Sumitkalamkar)

---

<div align="center">

Built while learning DevOps through the **GeeksForGeeks DevOps Course**  
using Jenkins · AWS · Docker · SonarQube · GitHub Actions

</div>
