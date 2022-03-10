// Copyright 2018 – 2020, MIT Lincoln Laboratory
// SPDX-License-Identifier: X11
pipeline {
   agent any

    stages {
        stage('all') {

            // Set system environment variables
            // These will be overwritten
            environment {
                outname = "foo"
               // AEM_DIR_CORE = "${env.WORKSPACE}/em-core"
              //  AEM_DIR_BAYES = "${env.WORKSPACE}/em-model-manned-bayes"
               // AEM_DIR_DAAENC = "${env.WORKSPACE}/em-pairing-uncor-importancesampling"
            }

            steps {
                node('master') {
                    dir('em-core') {
                        git 'git://llcad-github.llan.ll.mit.edu/airspace-encounter-models-internal/em-core.git'
                        script {
                            env.AEM_DIR_CORE = "${env.WORKSPACE}/em-core"
                        }
                        sh label: '', script: 'bash ./script/bootstrap.sh'
                        //sh label: '', script: 'bash ./script/setup.sh'
                    }
                    dir('em-model-manned-bayes') {
                        git 'git://llcad-github.llan.ll.mit.edu/airspace-encounter-models-internal/em-model-manned-bayes.git'
                        script {
                            env.AEM_DIR_BAYES = "${env.WORKSPACE}/em-model-manned-bayes"
                        }
                    }
                    dir('em-pairing-uncor-importancesampling') {
                        git 'git://llcad-github.llan.ll.mit.edu/airspace-encounter-models-internal/em-pairing-uncor-importancesampling'
                        script {
                            env.AEM_DIR_DAAENC = "${env.WORKSPACE}/em-pairing-uncor-importancesampling"
                        }

                        // debugging
                        sh 'printenv'

                        // mex
                        sh label: '', script: '/opt/matlab/2018a/bin/matlab -nodisplay -r "mex Encounter_Generation_Tool/run_dynamics_fast.c;mex Tests/Code/Helper_Functions/run_dynamics_fast_test.c;exit"'

                        // This would be a good place to check if a mex file exists

                        // Test on different versions of matlab
                        sh label: '', script: '/opt/matlab/2019a/bin/matlab -nodisplay -r "cd Tests/Unit_Tests/;RUN_tests;exit"'
                        ///sh label: '', script: '/opt/matlab/2018b/bin/matlab -nodisplay -r "cd Tests/Unit_Tests/;RUN_tests;exit"'

                        // Archive Arifacts
                        // https://stackoverflow.com/q/40597655/363829
                        archiveArtifacts artifacts: 'Tests/**/*.*', followSymlinks: false
                    } // dir
                } //node
            } // steps
        } //stage
    } //stages
    post { 
        always { 
            // Clean up workspace
             deleteDir()

            // https://stackoverflow.com/a/47882245/363829
            mail body: "<br>Project: ${env.JOB_NAME} <br>Build Number: ${env.BUILD_NUMBER} <br> Build URL: ${env.BUILD_URL}", charset: 'UTF-8', from: '', mimeType: 'text/html', replyTo: '', subject: "JENKINS, Job Name: ${env.JOB_NAME}, Build #: ${env.BUILD_NUMBER}", to: "Andrew.Weinert@ll.mit.edu,Christine.Chen@ll.mit.edu", cc: '', bcc: '';  
        }
    }
} //pipeline
