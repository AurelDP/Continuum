pipeline {
  environment {
    imagename = "aureldp/continuum"
    registryCredential = 'dockerhub_id'
    dockerImage = ''
  }
  agent { label 'slave' }
  stages {
    stage('Cloning Git') {
      steps {
        git([url: 'git@github.com:AurelDP/Continuum.git', branch: 'main', credentialsId: 'github_id'])
      }
    }
    stage('Building image') {
      steps{
        script {
          dir('dev') {
            dockerImage = docker.build imagename + ":$BUILD_NUMBER"
          }
        }
      }
    }
    stage('Deploy Image') {
      steps{
        script {
          docker.withRegistry( '', registryCredential ) {
            dockerImage.push()
          }
        }
      }
    }
    stage('Remove Unused docker image') {
      steps{
        sh "docker rmi $imagename:$BUILD_NUMBER"
      }
    }
  }
}