pipeline {
  agent {
    dockerfile {
      label 'docker && !smol'
      additionalBuildArgs '--build-arg K_COMMIT="$(cd deps/evm-semantics/deps/k && git rev-parse --short=7 HEAD)" --build-arg USER_ID=$(id -u) --build-arg GROUP_ID=$(id -g)'
    }
  }
  options { ansiColor('xterm') }
  stages {
    stage('Init title') {
      when { changeRequest() }
      steps { script { currentBuild.displayName = "PR ${env.CHANGE_ID}: ${env.CHANGE_TITLE}" } }
    }
    stage('Build and Test') {
      stages {
        stage('Build') {
          parallel {
            stage('KEVM')                        { steps { sh 'cd bytecode-verification && make deps-kevm RELEASE=true -j6' } }
            stage('Bytecode Verification Specs') { steps { sh 'cd bytecode-verification && make specs     RELEASE=true -j6' } }
            stage('Algorithm Correctness')       { steps { sh 'cd algorithm-correctness && make build     RELEASE=true -j6' } }
          }
        }
        stage('Test Execution') {
          options { timeout(time: 25, unit: 'MINUTES') }
          parallel {
            stage('Bytecode Verification')            { steps { sh 'cd bytecode-verification && make verify        -j4' } }
            stage('Algorithm Correctness - Concrete') { steps { sh 'cd algorithm-correctness && make test-concrete -j4' } }
            stage('Algorithm Correctness - Symbolic') { steps { sh 'cd algorithm-correctness && make test-symbolic -j4' } }
          }
        }
      }
    }
  }
}
