#!/bin/bash

# generate help files for postgres versions
# usage: ./generate_help_files.sh

# Get available PostgreSQL versions from DockerHub
NAMESPACE="library"
IMAGE="postgres"
TOKEN="$(curl -s "https://auth.docker.io/token?scope=repository:${NAMESPACE}/${IMAGE}:pull&service=registry.docker.io" | jq -r '.token')"
VERSIONS=$(curl -s -H "Authorization: Bearer ${TOKEN}" "https://registry-1.docker.io/v2/${NAMESPACE}/${IMAGE}/tags/list" \
           | jq -r '.tags[]' | grep -E '^[0-9]+(\.|[a-z]+)[0-9]+$' | sort -rV)

PG_USER="postgres"
LOG_FILE="processed_versions.log"
mkdir -p help_files

# Read processed versions from log file
if [ -f "$LOG_FILE" ]; then
    PROCESSED_VERSIONS=$(cat "$LOG_FILE")
else
    PROCESSED_VERSIONS=""
fi

COUNTER = 0
echo "Starting containers..."
for VERSION in $VERSIONS; do
    # Skip already processed versions
    if echo "$PROCESSED_VERSIONS" | grep -q "$VERSION"; then
        echo "Version $VERSION already processed, skipping..."
        continue
    fi

    # Process up to 3 versions at once
    COUNTER=$((COUNTER+1))
    if [ $COUNTER -gt 3 ]; then
        echo "Reached the limit of 3 versions, exiting..."
        break
    fi

    CONTAINER_NAME=postgres_$VERSION

    # Start container
    docker run --name $CONTAINER_NAME -e POSTGRES_PASSWORD=mysecretpassword -d postgres:$VERSION

    # Wait for the PostgreSQL server to start
    echo "Waiting for PostgreSQL server in container $CONTAINER_NAME to start..."
    until docker exec -i $CONTAINER_NAME pg_isready -U $PG_USER > /dev/null 2>&1; do
        sleep 1
    done
    echo "PostgreSQL server in container $CONTAINER_NAME is ready."

    echo "Generating help files for $VERSION..."

    # Generate help files
    KEYWORDS=$(docker exec -i $CONTAINER_NAME psql -U $PG_USER -c "\h" | sed -r "s/  +/\n/g" | sort | uniq | grep -v "^\s*$" | grep -v "Available help:")

    mkdir -p help_files/$CONTAINER_NAME

    IFS=$'\n'
    for kw in $KEYWORDS; do
        echo "Processing command: $kw in $CONTAINER_NAME"
        docker exec -i $CONTAINER_NAME psql -U $PG_USER -c "\h $kw" > "help_files/$CONTAINER_NAME/${kw}.txt"
    done

    echo "Removing container $CONTAINER_NAME..."
    docker rm -f $CONTAINER_NAME

    # Log processed version
    echo $VERSION >> $LOG_FILE
done

echo "Finished generating help files."
