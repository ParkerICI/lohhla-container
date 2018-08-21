set -ex
# SET THE FOLLOWING VARIABLES
USERNAME=gcr.io/pici-internal
# image name
IMAGE=lohhla
sudo docker build -t $USERNAME/$IMAGE:latest .
