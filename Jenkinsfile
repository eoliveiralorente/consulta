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
            steps {
                withCredentials([file(credentialsId: 'd52f91b2-fc33-4442-b030-921750c2250f', variable: 'kubeconfig')]){
                       sh 'curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"'
                       sh 'chmod u+x ./kubectl'
                       sh "./kubectl apply -f ."
                       sh "sleep 60"
                       sh "kubectl get all"
                    }
                }  
            }
        }
    }
}
