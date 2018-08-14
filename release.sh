set -ex
# SET THE FOLLOWING VARIABLES
# docker hub username
USERNAME=gcr.io/pici-internal
# image name
IMAGE=lohhla
#Copy to lohhla-container repo so they stay synced
sudo cp Dockerfile ~/lohhla-container/Dockerfile
# ensure we're up to date
sudo git pull
# bump version
sudo docker run --rm -v "$PWD":/app treeder/bump patch
version=`cat VERSION`
echo "version: $version"
# run build
sudo ./build.sh
# tag it
sudo git add -A
sudo git commit -m "version $version"
sudo git tag -a "$version" -m "version $version"
sudo git push
sudo git push --tags
sudo docker tag $USERNAME/$IMAGE:latest $USERNAME/$IMAGE:$version
# push it
sudo gcloud docker push $USERNAME/$IMAGE:latest
sudo gcloud docker push $USERNAME/$IMAGE:$version

#Print the version again
echo "version: $version"
echo "Container: ${USERNAME}/${IMAGE}:${version}


