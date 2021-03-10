def call() {
    podTemplate(yaml: """
kind: Pod
metadata:
  name: kaniko
spec:
  containers:
  - name: kaniko
    image: gcr.io/kaniko-project/executor:debug
    imagePullPolicy: IfNotPresent
    command:
    - /busybox/cat
    tty: true
    env:
      - name: GIT_ACCESS_TOKEN
        value: testToken    
  - name: git
    image: alpine/git:latest
    imagePullPolicy: IfNotPresent
    command:
    - cat
    tty: true    
"""
    ) {
        node('Build and Push') {

            def scmVars = checkout scm

                stage('Build with Kaniko') {
                    withEnv(["PATH=/busybox:/kaniko:$PATH"
                    ]) {
                        container(name: 'kaniko', shell: '/busybox/sh') {
                                String dockerfile = "app/Dockerfile";
                                String repoName = "myRepoName"
                                String image = "${repoName}/myapp";
                                sh """
                                    echo \"Building docker image,  ${image}\"
                                    /kaniko/executor -f `pwd`/${dockerfile}
                                    --destination=${image}
                                """
                                echo "${image} pushed successfully!"
                            
                        }
                    }
                }
            }


        }
    }
