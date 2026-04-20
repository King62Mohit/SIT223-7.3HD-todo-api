# SonarQube Setup for Jenkins

## Step 1: Get SonarQube Token

1. Open http://localhost:9000 in browser
2. Login: **admin / admin** (or check if you already changed it)
3. Click your profile (top right) → **My Account** → **Security**
4. Under "Generate Tokens", type a name like "jenkins"
5. Click **Generate** and COPY the token (you won't see it again!)

## Step 2: Configure Jenkins

1. Open http://localhost:8080
2. Go to **Manage Jenkins** → **System**
3. Scroll to **SonarQube servers**
4. Check **Enable injection**
5. Click **Add SonarQube**
   - Name: `SonarQube`
   - Server URL: `http://localhost:9000`
   - Server authentication token: **Add** → **Jenkins**
     - Kind: Secret text
     - Secret: (paste your token from Step 1)
     - ID: `sonarqube-token`
     - Click **Add**
   - Select the token you just added
6. Click **Save**

## Step 3: Configure SonarQube Webhook (CRITICAL)

The `waitForQualityGate` step requires SonarQube to notify Jenkins when analysis completes.

1. Open http://localhost:9000 and login as **admin**
2. Go to **Administration** → **Configuration** → **Webhooks**
3. Click **Create**
   - Name: `Jenkins`
   - URL: `http://localhost:8080/sonarqube-webhook/`
   - Secret: (leave blank)
4. Click **Create**

## Step 4: Run Pipeline

Go to your **todo-api** job in Jenkins and click **Build Now**!

## Troubleshooting

### Quality Gate Timeout

If you see "Timeout has been exceeded" during Code Quality stage:

**Cause:** SonarQube webhook not configured, or background processing is slow.

**Quick Fix:** The pipeline now waits up to 10 minutes and continues if timed out.

**Proper Fix:** Ensure webhook is configured (Step 3 above) and SonarQube server is running.

### Check SonarQube Status

If SonarQube is not running:
```bash
docker start sonarqube
```

Check analysis task status: http://localhost:9000/api/ce/task?id=YOUR_TASK_ID

Default login: **admin / admin**
