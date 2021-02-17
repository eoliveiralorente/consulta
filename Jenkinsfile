pipeline {
environment {
    registry = "eoliveiralorente/api-s3"
    registryCredential = 'dockerhub_id'
    dockerImage = ''
}
    agent any
    
        stages {
            
        stage('Clonar git') {
          steps {
            script {
              git([url:'https://github.com/eoliveiralorente/consulta.git', branch:'main', credentialsId: 'eoliveiralorente_id'])
            }           
          }
        }

        stage('Docker build') {
            steps {
                script {
                 dockerImage = docker.build registry + ":$BUILD_NUMBER"   
              }
            }
        }
        
        stage('Scan Vulnerabilidade'){
            steps {
                sh '''
                     docker pull arminc/clair-db:latest
                     docker pull arminc/clair-local-scan:v2.1.5_3ce78db2bff803f1198a8659c53a3e79a371a6c9
                     docker rm -f db
                     docker run -d --name db arminc/clair-db
                     sleep 10
                     docker rm -f clair
                     docker run -p 6060:6060 --link db:postgres -d --name clair arminc/clair-local-scan:v2.1.5_3ce78db2bff803f1198a8659c53a3e79a371a6c9
                     sleep 1
                     DOCKER_GATEWAY=$(docker network inspect bridge --format "{{range .IPAM.Config}}{{.Gateway}}{{end}}")
                     wget https://github.com/arminc/clair-scanner/releases/download/v8/clair-scanner_linux_amd64
                     mv clair-scanner_linux_amd64 clair-scanner
                     chmod +x clair-scanner
                     touch clair-whitelist.yml
                     echo "Iniciar clair"
                     ./clair-scanner --ip="$DOCKER_GATEWAY" -r gl-container-scanning-report.json -l clair.log -w clair-whitelist.yml ${dockerImage} || true
                     cat gl-container-scanning-report.json
                '''
            }
        }

        stage('Docker push') {
            steps {
                script {
                docker.withRegistry('https://registry.hub.docker.com',registryCredential ) {
                dockerImage.push()
                }
             }
          }
       }

        stage('Deploy') {
            steps {
                withCredentials([file(credentialsId: 'd52f91b2-fc33-4442-b030-921750c2250f', variable: 'kubeconfig')]){
                       sh 'curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"'
                       sh 'chmod u+x ./kubectl'
                       sh "./kubectl apply -f ."
                       sh "sleep 60"
                       sh "./kubectl get all"
                    }
                }  
            }
        }
    }
