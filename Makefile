ROOT := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
ARGS = $(filter-out $@,$(MAKECMDGOALS))
MAKEFLAGS += --silent

clean:
	rm -rf ./binaries/*
	docker ps --format "{{.Image}} {{.ID}}" | grep "python" | cut -d " " -f 2 | xargs -I {} docker stop {} > /dev/null
	docker ps -a --format "{{.Image}} {{.ID}}" | grep "python" | cut -d " " -f 2 | xargs -I {} docker rm --force {} > /dev/null
	docker images --format "{{.Repository}}:{{.ID}}" | grep "python" | sed -n -e "s/^python://p" | xargs -I {} docker rmi --force {} > /dev/null
	docker ps --format "{{.Image}} {{.ID}}" | grep "tarampampam/curl" | cut -d " " -f 2 | xargs -I {} docker stop {} > /dev/null
	docker ps -a --format "{{.Image}} {{.ID}}" | grep "tarampampam/curl" | cut -d " " -f 2 | xargs -I {} docker rm --force {} > /dev/null
	docker images --format "{{.Repository}}:{{.ID}}" | grep "tarampampam/curl" | sed -n -e "s/^tarampampam\/curl://p" | xargs -I {} docker rmi --force {} > /dev/null
	docker ps --format "{{.Image}} {{.ID}}" | grep "qoopido/telerising.minimal" | cut -d " " -f 2 | xargs -I {} docker stop {} > /dev/null
	docker ps -a --format "{{.Image}} {{.ID}}" | grep "qoopido/telerising.minimal" | cut -d " " -f 2 | xargs -I {} docker rm --force {} > /dev/null
	docker images --format "{{.Repository}}:{{.ID}}" | grep "qoopido/telerising.minimal" | sed -n -e "s/^qoopido\/telerising.minimal://p" | xargs -I {} docker rmi --force {} > /dev/null

build:
	docker ps --format "{{.Image}} {{.ID}}" | grep "qoopido/telerising.minimal" | cut -d " " -f 2 | xargs -I {} docker stop {} > /dev/null
	docker ps -a --format "{{.Image}} {{.ID}}" | grep "qoopido/telerising.minimal" | cut -d " " -f 2 | xargs -I {} docker rm --force {} > /dev/null
	docker buildx build --platform linux/amd64,linux/arm64,linux/arm/v7 --no-cache --compress --push -t qoopido/telerising.minimal:0.9.2 -t qoopido/telerising.minimal:latest .
	docker buildx build --platform linux/amd64 --target builder --compress --load -t qoopido/telerising.minimal:amd64-builder .
	docker buildx build --platform linux/arm64 --target builder --compress --load -t qoopido/telerising.minimal:arm64-builder .
	docker buildx build --platform linux/arm/v7 --target builder --compress --load -t qoopido/telerising.minimal:arm-builder .
	docker create --name=telerising-amd64 --platform linux/amd64 qoopido/telerising.minimal:amd64-builder
	docker create --name=telerising-arm64 --platform linux/arm64 qoopido/telerising.minimal:arm64-builder
	docker create --name=telerising-arm --platform linux/arm/v7 qoopido/telerising.minimal:arm-builder
	rm -rf ./binaries/*
	docker container cp telerising-amd64:/var/app/telerising.dist/ ./binaries/amd64
	docker container cp telerising-arm64:/var/app/telerising.dist/ ./binaries/arm64
	docker container cp telerising-arm:/var/app/telerising.dist/ ./binaries/arm
	tar -czvf ./binaries/telerising.amd64.tar.gz -C ${ROOT}binaries/amd64 ./
	tar -czvf ./binaries/telerising.arm64.tar.gz -C ${ROOT}binaries/arm64 ./
	tar -czvf ./binaries/telerising.arm.tar.gz -C ${ROOT}binaries/arm ./
	rm -rf ./binaries/amd64 ./binaries/arm64 ./binaries/arm
	docker ps --format "{{.Image}} {{.ID}}" | grep "qoopido/telerising.minimal" | cut -d " " -f 2 | xargs -I {} docker stop {} > /dev/null
	docker ps -a --format "{{.Image}} {{.ID}}" | grep "qoopido/telerising.minimal" | cut -d " " -f 2 | xargs -I {} docker rm --force {} > /dev/null

#############################
# Argument fix workaround
#############################
%:
	@:
