#!/bin/bash
# Jenkins Setup Script for SIT223-7.3HD

echo "=========================================="
echo "Jenkins Setup Helper"
echo "=========================================="
echo ""

# Check if Jenkins is running
if pgrep -f "jenkins" > /dev/null; then
    echo "Jenkins is already running!"
    echo "Access it at: http://localhost:8080"
else
    echo "Starting Jenkins..."
    brew services start jenkins-lts
    echo "Jenkins starting... wait 30 seconds then access:"
    echo "http://localhost:8080"
fi

echo ""
echo "=========================================="
echo "Initial Admin Password:"
echo "=========================================="
cat /Users/$(whoami)/.jenkins/secrets/initialAdminPassword 2>/dev/null || echo "Password file not found - Jenkins may already be configured"

echo ""
echo "=========================================="
echo "Next Steps:"
echo "=========================================="
echo "1. Open http://localhost:8080 in browser"
echo "2. Enter the initial admin password above"
echo "3. Install suggested plugins"
echo "4. Create admin user"
echo "5. Go to Manage Jenkins → Plugins → Available"
echo "   Install: Docker Pipeline, SonarQube Scanner, HTML Publisher, JUnit, NodeJS"
echo ""
echo "6. Go to Manage Jenkins → Tools:"
echo "   - Add NodeJS: Name 'NodeJS-18', install automatically"
echo "   - Add SonarQube Scanner: Name 'SonarQube-Scanner', install automatically"
echo ""
echo "7. Go to Manage Jenkins → System:"
echo "   - Add SonarQube server:"
echo "     Name: SonarQube"
echo "     URL: http://localhost:9000"
echo "     Token: (generate in SonarQube at User → My Account → Security → Tokens)"
echo ""
echo "8. Create new Pipeline job:"
echo "   - Name: todo-api"
echo "   - Pipeline from SCM: Git"
echo "   - Repository: https://github.com/King62Mohit/SIT223-7.3HD-todo-api.git"
echo "   - Branch: */main"
echo "   - Script Path: Jenkinsfile"
echo ""
