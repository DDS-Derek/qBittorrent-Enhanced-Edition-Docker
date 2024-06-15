#!/bin/bash

Green="\033[32m"
Red="\033[31m"
Yellow='\033[33m'
Font="\033[0m"
INFO="[${Green}INFO${Font}]"
ERROR="[${Red}ERROR${Font}]"
WARN="[${Yellow}WARN${Font}]"
function INFO() {
echo -e "${INFO} ${1}"
}
function ERROR() {
echo -e "${ERROR} ${1}"
}
function WARN() {
echo -e "${WARN} ${1}"
}


function get_info(){
WORKDIR=$(pwd)
INFO "WorkDir=${WORKDIR}"

CONFIG_FILE_DIR=/etc/DDSRem/config.json

Builder_Name=builder_ddsrem_$(date -u +"T%H%M%S%3NZ")

Github_Token=$(jq -r '.Github_Token' ${CONFIG_FILE_DIR})
Dockerhub_Username=$(jq -r '.Dockerhub_Username' ${CONFIG_FILE_DIR})
Dockerhub_Password=$(jq -r '.Dockerhub_Password' ${CONFIG_FILE_DIR})
DockerHub_Repo_Name=$(jq -r '.DockerHub_Repo_Name' Build.json)
Github_Repo=$(jq -r '.Github_Repo' Build.json)
Branches=$(jq -r '.Branches' Build.json)
Version_qb=$(eval echo $(jq -r '.Version_qb' Build.json))
Version_qbee=$(eval echo $(jq -r '.Version_qbee' Build.json))
Dockerfile_Name=$(jq -r '.Dockerfile_Name' Build.json)
ARCH=$(jq -r '.ARCH' Build.json)
ARG=$(eval echo $(jq -r '.ARG' Build.json))
TAG=$(eval echo $(jq -r '.TAG' Build.json))
DockerHub_Repo="${Dockerhub_Username}/${DockerHub_Repo_Name}"
GITHUB_API=$(curl -s -H "Authorization: token ${Github_Token}" -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/${Github_Repo})
image_created=$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ")
image_description=$(echo ${GITHUB_API} | jq -r ".description")
image_licenses=$(echo ${GITHUB_API} | jq -r ".license.name")
image_revision=$(curl -s -H "Authorization: token ${Github_Token}" -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/${Github_Repo}/commits/${Branches} | jq -r ".sha")
image_source=$(echo ${GITHUB_API} | jq -r ".html_url")
image_title=$(echo ${GITHUB_API} | jq -r ".name")
image_url=$(echo ${GITHUB_API} | jq -r ".html_url")
image_version=${Version_qb}

INFO "org.opencontainers.image.created=${image_created}"
INFO "org.opencontainers.image.description=${image_description}"
INFO "org.opencontainers.image.licenses=${image_licenses}"
INFO "org.opencontainers.image.revision=${image_revision}"
INFO "org.opencontainers.image.source=${image_source}"
INFO "org.opencontainers.image.title=${image_title}"
INFO "org.opencontainers.image.url=${image_url}"
INFO "org.opencontainers.image.version=${image_version}"
INFO "DockerHub_Repo_Name=${DockerHub_Repo_Name}"
INFO "DockerHub_Repo=${DockerHub_Repo}"
INFO "Github_Repo=${Github_Repo}"
INFO "Branches=${Branches}"
INFO "Version=${Version_qbee}"
INFO "Dockerfile_Name=${Dockerfile_Name}"
INFO "ARCH=${ARCH}"
INFO "ARG=${ARG}"
INFO "TAG=${TAG}"
}

function prepare_build() {
docker run -d \
    --name=${Builder_Name} \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v ${WORKDIR}:/build \
    --workdir /build \
    dockerhub.ddsrem.in:998/catthehacker/ubuntu@sha256:3ad2f8684955514d9ddf942efc9078f3cb02ffe5ebbb6a5af655a783ffe3062f tail -f /dev/null
docker exec -it ${Builder_Name} uname -a
docker exec -it ${Builder_Name} mkdir -p ${HOME}/.docker/cli-plugins
docker exec -it ${Builder_Name} curl -sL https://github.com/christian-korneck/docker-pushrm/releases/download/v1.9.0/docker-pushrm_linux_amd64 -o ${HOME}/.docker/cli-plugins/docker-pushrm
docker exec -it ${Builder_Name} chmod +x ${HOME}/.docker/cli-plugins/docker-pushrm
docker exec -it ${Builder_Name} docker pull tonistiigi/binfmt
docker exec -it ${Builder_Name} docker run --privileged --rm tonistiigi/binfmt --install all
docker exec -it ${Builder_Name} docker buildx create --name ${Builder_Name} --use 2>/dev/null || docker buildx use builder
docker exec -it ${Builder_Name} docker buildx inspect --bootstrap
docker exec -it ${Builder_Name} docker login --password ${Dockerhub_Password} --username ${Dockerhub_Username}
}

function clear_build() {
docker exec -it ${Builder_Name} docker logout
docker exec -it ${Builder_Name} docker buildx rm ${Builder_Name}
docker stop ${Builder_Name}
docker rm ${Builder_Name}
docker image rm moby/buildkit:buildx-stable-1
}

function build_image() {
git clone -b master https://github.com/devome/dockerfiles.git files
cp -r files/qbittorrent/root root
cp -r files/qbittorrent/root2 root2
ls -al
ls -al root
ls -al root2
docker exec -it ${Builder_Name} \
    docker buildx build \
    ${ARG} \
    --file ${Dockerfile_Name} \
    --label "org.opencontainers.image.created=${image_created}" \
    --label "org.opencontainers.image.description=${image_description}" \
    --label "org.opencontainers.image.licenses=${image_licenses}" \
    --label "org.opencontainers.image.revision=${image_revision}" \
    --label "org.opencontainers.image.source=${image_source}" \
    --label "org.opencontainers.image.title=${image_title}" \
    --label "org.opencontainers.image.url=${image_url}" \
    --label "org.opencontainers.image.version=${image_version}" \
    --platform ${ARCH} \
    ${TAG} \
    --push \
    .
docker exec -it ${Builder_Name} \
    docker buildx build \
    --build-arg VERSION=${Version_qb} \
    --build-arg REPO_NAME=${Dockerhub_Username}/${DockerHub_Repo_Name} \
    --file iyuu.${Dockerfile_Name} \
    --label "org.opencontainers.image.created=${image_created}" \
    --label "org.opencontainers.image.description=${image_description}" \
    --label "org.opencontainers.image.licenses=${image_licenses}" \
    --label "org.opencontainers.image.revision=${image_revision}" \
    --label "org.opencontainers.image.source=${image_source}" \
    --label "org.opencontainers.image.title=${image_title}" \
    --label "org.opencontainers.image.url=${image_url}" \
    --label "org.opencontainers.image.version=${image_version}-iyuu" \
    --platform ${ARCH} \
    --tag ${Dockerhub_Username}/${DockerHub_Repo_Name}:${Version}-iyuu \
    --tag ${Dockerhub_Username}/${DockerHub_Repo_Name}:latest-iyuu \
    --push \
    .
}

get_info

prepare_build

build_image

clear_build