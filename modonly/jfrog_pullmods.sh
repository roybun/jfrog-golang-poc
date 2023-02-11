if [ ! -f jfrog_vars.env ]; then
  echo "jfrog_vars.env not found, exiting"
  exit 2
fi

. jfrog_vars.env
export GOPROXY="https://${ARTIFACTORY_USERNAME}:${ARTIFACTORY_API_TOKEN}@\
${JFROGPLATFORMURI}/artifactory/api/go/${ARTIFACTORY_VIRTUAL_REPO_NAME}"

echo "Clearing local go cache to force pull from artifactory\
 (Thus causing artifactory to cache all packages)"
go clean -modcache
echo "Downloading all packages in the go.mod file"
go mod download -json