def label = "kaniko-${UUID.randomUUID().toString()}"
def unit  = "phpunit-${UUID.randomUUID().toString()}"
podTemplate(name: 'kaniko', label: label, yaml: """
kind: Pod
metadata:
  name: kaniko
spec:
  containers:
  - name: kaniko
    image: gcr.io/kaniko-project/executor:debug
    imagePullPolicy: Always
    command:
    - /busybox/cat
    tty: true
    volumeMounts:
      - name: jenkins-docker-cfg
        mountPath: /kaniko/.docker
  volumes:
  - name: ocirsecret
    projected:
      sources:
      - secret:
          name: jenkins-docker-cfg
          items:
            - key: .dockerconfigjson
              path: config.json               
"""
  ) 



  {
  node(label) {
    stage('Build Kaniko') {
      git 'https://github.com/SilvioCristiano/cloudnative.git'
      container(name: 'kaniko', shell: '/busybox/sh') {
          sh '''#!/busybox/sh
          /kaniko/executor -f Dockerfile -c `pwd` --destination=jacksonlima91/forum-app:$BUILD_NUMBER 
          '''
      }
    }
   }
  }
podTemplate(name: 'phpunit', label: unit, yaml: """
kind: Pod
metadata:
  name: two-containers
spec:
  containers:
  - name: backend
    image: jacksonlima91/forum-app:$BUILD_NUMBER

  - name: mysql
    image: mysql:5.7
    args:
        - "--ignore-db-dir=lost+found"
    env:
        - name: MYSQL_ROOT_PASSWORD
          value: schoolofnet
        - name: MYSQL_PASSWORD
          value: secret
        - name: MYSQL_DATABASE
          value: homestead
        - name: MYSQL_USER
          value: laravel_user
    ports:
    - containerPort: 3306
      name: mysql         
"""
  ) 

  {
  node(unit) {
    stage('Unit Test') {
      container(name: 'backend', shell: '/bin/bash') {
          sh '/var/www/forum/waitforit.sh localhost:3306 -t 90'
          sh '/var/www/forum/vendor/bin/phpunit -c /var/www/forum/phpunit.xml'
      }
    }
  }
  }
  node {
  stage('Deploy Dev') {
    if (env.BRANCH_NAME.equals('develop')){
    container(name: 'kubectl')  {
     withKubeConfig([credentialsId: 'kubectl', serverUrl: 'https://129.213.189.32:6443', contextName: 'context-czdutlcmj2q', clusterName: 'cluster-czdutlcmj2q']) {
      sh 'kubectl set image iad.ocir.io/oraclemetodista/ocir-repo/cloudnative:$BUILD_NUMBER -n develop'
    }
    }
      }
  }
}
  node {
  stage('Deploy Prod') {
    if (env.BRANCH_NAME.equals('master')){
    container(name: 'kubectl')  {
     withKubeConfig([credentialsId: 'kubectl', serverUrl: 'https://129.213.189.32:6443', contextName: 'context-czdutlcmj2q', clusterName: 'cluster-czdutlcmj2q']) {
      sh 'kubectl set image iad.ocir.io/oraclemetodista/ocir-repo/cloudnative:$BUILD_NUMBER'
    }
    }
      }
  }
}

slackSend channel: '#deploy-com-jenkins',color: 'good',message: "*${currentBuild.currentResult}:* Job ${env.JOB_NAME} build ${env.BUILD_NUMBER}\n More information at: ${env.BUILD_URL}"  
          
     
