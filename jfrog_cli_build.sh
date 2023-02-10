JFROGPLATFORMURI=https://<username>:@<url>
ARTIFACTORY_API_TOKEN=<APIToken>
ARTIFACTORY_USERNAME=<artifactory-username>
ARTIFACTORY_LOCAL_REPO_NAME=<artifactory-local-repo-name>
ARTIFACTORY_REMOTE_REPO_NAME=<artifactory-remote-repo-name>
ARTIFACTORY_VIRTUAL_REPO_NAME=<artifactory-virtual-repo-name>
JF_BUILD_NAME=<build name>
JF_BUILD_NUMBER=<buildnumber>
JF_BUILD_VERSION=<buildVersion> (Must be format vX.Y.Z <semantic>)

#Install JFrog CLI
# brew install jfrog-cli in MACOS
#Make sure go 1.18 or higher is installed on machine
#Configure JFrog CLI itself to be aware of the artifactory server
jf c add artifactory-server -url $JFROGPLATFORMURI --user $ARTIFACTORY_USERNAME \
  --password $ARTIFACTORY_API_TOKEN --interactive=false
#Configure JFrog go client to resolve dependencies with the virtual repo and 
# deploy proprietary builds to the local repo
jf go-config --server-id-resolve artifactory-server \
  --repo-resolve $ARTIFACTORY_VIRTUAL_REPO_NAME \
  --repo-deploy $ARTIFACTORY_LOCAL_REPO_NAME

#Force go to re-download modules and not use local system cache, to force artifactory fetching
go clean -modcache
jf go build --build-name $JF_BUILD_NAME --build-number $JF_BUILD_NUMBER
jf gp $JF_BUILD_VERSION --build-name=$JF_BUILD_NAME --build-number=$JF_BUILD_NUMBER
jf rt bp $JF_BUILD_NAME $JF_BUILD_NUMBER