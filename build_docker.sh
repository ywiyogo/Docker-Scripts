#!/bin/bash

# build_docker.sh with additional options

# Default values
IMAGE_NAME="ubuntu24_on_cachy"
IMAGE_TAG="latest"
DOCKERFILE="ubuntu_on_cachy.dockerfile"


# Function to print usage
print_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Build a Docker image with current user credentials"
    echo
    echo "Options:"
    echo "  -d, --dockerfile PATH    Path to Dockerfile (default: $DEFAULT_DOCKERFILE)"
    echo "  -n, --name NAME          Image name (default: $DEFAULT_IMAGE_NAME)"
    echo "  -t, --tag TAG            Image tag (default: $DEFAULT_IMAGE_TAG)"
    echo "  -h, --help               Show this help message"
    echo
    echo "Example:"
    echo "  $0 --dockerfile ./Dockerfile.dev --name my-dev-env --tag v1.0"
}

# Parse command line arguments
DOCKERFILE=$DEFAULT_DOCKERFILE
IMAGE_NAME=$DEFAULT_IMAGE_NAME
IMAGE_TAG=$DEFAULT_IMAGE_TAG

while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--dockerfile)
            DOCKERFILE="$2"
            shift 2
            ;;
        -n|--name)
            IMAGE_NAME="$2"
            shift 2
            ;;
        -t|--tag)
            IMAGE_TAG="$2"
            shift 2
            ;;
        -h|--help)
            print_usage
            exit 0
            ;;
        *)
            echo "Error: Unknown option $1"
            print_usage
            exit 1
            ;;
    esac
done

# Get current user details
CURRENT_USER=$(whoami)
CURRENT_UID=$(id -u)
CURRENT_GID=$(id -g)

# Verify required files exist
if [ ! -f "$DOCKERFILE" ]; then
    echo "Error: Dockerfile not found at $DOCKERFILE"
    exit 1
fi

# Print build information
echo "Docker Build Configuration:"
echo "------------------------"
echo "Dockerfile: $DOCKERFILE"
echo "Image Name: $IMAGE_NAME"
echo "Image Tag:  $IMAGE_TAG"
echo "User:       $CURRENT_USER"
echo "UID:        $CURRENT_UID"
echo "GID:        $CURRENT_GID"
echo "------------------------"

# Build the image with build arguments
docker build \
    --build-arg USERNAME="$CURRENT_USER" \
    --build-arg USER_UID="$CURRENT_UID" \
    --build-arg USER_GID="$CURRENT_GID" \
    -t "$IMAGE_NAME:$IMAGE_TAG" \
    -f "$DOCKERFILE" \
    .

# Check if build was successful
if [ $? -eq 0 ]; then
    echo "Build successful!"
    echo "You can now run the container using:"
    echo "./run_docker_for_gui.sh $IMAGE_NAME:$IMAGE_TAG"
else
    echo "Build failed!"
    exit 1
fi