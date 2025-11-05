pipeline {
  agent any

  tools { nodejs 'node20' }

  environment {
    APP_HOST = '#########'   // <-- use your APP public IP
    APP_USER = 'deploy'
  }

  stages {
    stage('Checkout') {
      steps { checkout scm }
    }

    stage('Install deps') {
      steps {
        dir('my-vite-app') {
          sh '''
            set -eux
            if [ -f package-lock.json ]; then
              npm ci
            else
              npm install
            fi
          '''
        }
      }
    }

    stage('Build') {
      steps {
        dir('my-vite-app') {
          sh 'npm run build'
        }
      }
    }

    stage('Pack') {
      steps {
        dir('my-vite-app') {
          sh '''
            cd dist
            tar -czf ../vite-build.tar.gz .
            cd ..
            ls -lh vite-build.tar.gz
          '''
        }
      }
    }

    stage('Deploy to APP EC2') {
      steps {
        sshagent(credentials: ['deploy-ssh-app']) {
          sh '''
            set -eux
            ssh -o StrictHostKeyChecking=no ${APP_USER}@${APP_HOST} "echo 'SSH OK'"
            scp -o StrictHostKeyChecking=no scripts/deploy.sh ${APP_USER}@${APP_HOST}:/tmp/deploy.sh
            scp -o StrictHostKeyChecking=no my-vite-app/vite-build.tar.gz ${APP_USER}@${APP_HOST}:/tmp/vite-build.tar.gz
            ssh -o StrictHostKeyChecking=no ${APP_USER}@${APP_HOST} "chmod +x /tmp/deploy.sh && /tmp/deploy.sh"
          '''
        }
      }
    }
  }

  post {
    success { echo "✅ Deployed! Visit: http://${env.APP_HOST}" }
    failure { echo "❌ Deployment failed. Check console output." }
  }
}
