# Quick Start Guide - SIT223-7.3HD

## What's Already Running

All services are **already started** and running:

| Service | URL | Status |
|---------|-----|--------|
| Staging API | http://localhost:3000 | ✅ Running |
| Production API | http://localhost:3001 | ✅ Running |
| Prometheus | http://localhost:9090 | ✅ Running |
| Grafana | http://localhost:3002 | ✅ Running |
| SonarQube | http://localhost:9000 | ✅ Running |

## Quick Commands

### Test the API
```bash
./scripts/test-api.sh
```

### Stop All Services
```bash
./scripts/stop-all.sh
```

### Start All Services (if stopped)
```bash
./scripts/start-all.sh
```

### Run Tests
```bash
npm test
```

## Manual Testing

```bash
# Health check
curl http://localhost:3000/health

# Create a todo
curl -X POST http://localhost:3000/todos \
  -H "Content-Type: application/json" \
  -d '{"title":"My task"}'

# Get all todos
curl http://localhost:3000/todos
```

## Jenkins Setup (One-time)

Run this script for step-by-step instructions:
```bash
./scripts/setup-jenkins.sh
```

Or follow these steps:

1. **Open Jenkins:** http://localhost:8080

2. **Get initial password:**
   ```bash
   cat ~/.jenkins/secrets/initialAdminPassword
   ```

3. **Install plugins:**
   - Go to Manage Jenkins → Plugins → Available
   - Install: Docker Pipeline, SonarQube Scanner, HTML Publisher, JUnit, NodeJS

4. **Configure Tools:**
   - Manage Jenkins → Tools → Add NodeJS (name: `NodeJS-18`)
   - Add SonarQube Scanner (name: `SonarQube-Scanner`)

5. **Configure SonarQube:**
   - Manage Jenkins → System → SonarQube servers
   - Name: `SonarQube`, URL: `http://localhost:9000`
   - Token: Generate in SonarQube (User → My Account → Security → Tokens)

6. **Create Pipeline Job:**
   - New Item → Pipeline → Name: `todo-api`
   - Pipeline from SCM → Git
   - Repository: `https://github.com/King62Mohit/SIT223-7.3HD-todo-api.git`
   - Branch: `*/main`, Script Path: `Jenkinsfile`

7. **Build:** Click "Build Now"

## Project Structure

```
todo-api/
├── src/app.js              # Main application code
├── tests/todo.test.js      # Jest test files
├── scripts/                # Helper scripts
│   ├── setup-jenkins.sh   # Jenkins setup guide
│   ├── start-all.sh       # Start all containers
│   ├── stop-all.sh        # Stop all containers
│   └── test-api.sh        # Test API endpoints
├── ansible/                 # Ansible playbooks
├── k8s/                     # Kubernetes manifests
├── monitoring/              # Prometheus config
├── dockerfile               # Docker image definition
├── docker_compose.yml       # Multi-container setup
├── Jenkinsfile              # CI/CD pipeline
└── package.json             # Node.js dependencies
```

## Useful URLs

- **GitHub Repo:** https://github.com/King62Mohit/SIT223-7.3HD-todo-api
- **Staging API:** http://localhost:3000
- **Production API:** http://localhost:3001
- **Prometheus:** http://localhost:9090
- **Grafana:** http://localhost:3002 (admin/admin)
- **SonarQube:** http://localhost:9000
- **Jenkins:** http://localhost:8080

## Troubleshooting

### Jenkins won't start
```bash
brew services restart jenkins-lts
```

### Docker containers won't start
```bash
docker rm -f $(docker ps -aq)  # Remove all containers
docker system prune -f          # Clean up
./scripts/start-all.sh          # Restart
```

### Port already in use
```bash
lsof -ti:3000 | xargs kill -9  # Kill process on port 3000
```

## Assignment Requirements - Status

- ✅ **Source Code Management** (Git/GitHub)
- ✅ **CI/CD Pipeline** (Jenkinsfile with 7 stages)
- ✅ **Docker** (Dockerfile + docker-compose.yml)
- ✅ **Kubernetes** (k8s/deployment.yml, service.yml)
- ✅ **Ansible** (ansible/deploy.yml, monitoring.yml)
- ✅ **Monitoring** (Prometheus + Grafana)

All changes pushed to: https://github.com/King62Mohit/SIT223-7.3HD-todo-api
