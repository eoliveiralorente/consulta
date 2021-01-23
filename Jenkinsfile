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
            kubeconfig(credentialsId: 'd52f91b2-fc33-4442-b030-921750c2250f', serverUrl: 'https://192.168.49.2:8443') {
                sh "kubectl apply -f ."
                sh "sleep 60"
                sh "kubectl get all"
            }
        }
    }
}
