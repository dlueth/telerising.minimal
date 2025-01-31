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

base:
	docker ps --format "{{.Image}} {{.ID}}" | grep "qoopido/telerising.builder" | cut -d " " -f 2 | xargs -I {} docker stop {} > /dev/null
	docker ps -a --format "{{.Image}} {{.ID}}" | grep "qoopido/telerising.builder" | cut -d " " -f 2 | xargs -I {} docker rm --force {} > /dev/null
	docker ps -a --format "{{.Image}} {{.ID}}" | grep "qoopido/telerising.builder" | cut -d " " -f 2 | xargs -I {} docker rmi --force {} > /dev/null
	docker buildx build --progress=plain --platform linux/amd64 --target base --compress --no-cache --force-rm --push -t qoopido/telerising.builder:amd64 -f Dockerfile.default .
	docker buildx build --progress=plain --platform linux/arm64/v8 --target base --compress --no-cache --force-rm --push -t qoopido/telerising.builder:arm64v8 -f Dockerfile.arm64v8.16k .
	docker buildx build --progress=plain --platform linux/arm/v7 --target base --compress --no-cache --force-rm --push -t qoopido/telerising.builder:arm32v7 -f Dockerfile.default .
	docker buildx build --progress=plain --platform linux/arm/v6 --target base --compress --no-cache --force-rm --push -t qoopido/telerising.builder:arm32v6 -f Dockerfile.arm32v6.4k .
	docker buildx imagetools create -t qoopido/telerising.builder:latest qoopido/telerising.builder:amd64 qoopido/telerising.builder:arm64v8 qoopido/telerising.builder:arm32v7 qoopido/telerising.builder:arm32v6

build:
	docker ps --format "{{.Image}} {{.ID}}" | grep "qoopido/telerising.build" | cut -d " " -f 2 | xargs -I {} docker stop {} > /dev/null
	docker ps -a --format "{{.Image}} {{.ID}}" | grep "qoopido/telerising.build" | cut -d " " -f 2 | xargs -I {} docker rm --force {} > /dev/null
	docker ps -a --format "{{.Image}} {{.ID}}" | grep "qoopido/telerising.build" | cut -d " " -f 2 | xargs -I {} docker rmi --force {} > /dev/null
	docker ps --format "{{.Image}} {{.ID}}" | grep "qoopido/telerising.minimal" | cut -d " " -f 2 | xargs -I {} docker stop {} > /dev/null
	docker ps -a --format "{{.Image}} {{.ID}}" | grep "qoopido/telerising.minimal" | cut -d " " -f 2 | xargs -I {} docker rm --force {} > /dev/null
	docker ps -a --format "{{.Image}} {{.ID}}" | grep "qoopido/telerising.minimal" | cut -d " " -f 2 | xargs -I {} docker rmi --force {} > /dev/null
	docker buildx build --progress=plain --platform linux/amd64 --target build --no-cache --force-rm --compress --load -t qoopido/telerising.build:amd64 -f Dockerfile.build .
	docker buildx build --progress=plain --platform linux/arm64/v8 --target build --no-cache --force-rm --compress --load -t qoopido/telerising.build:arm64v8 -f Dockerfile.build .
	docker buildx build --progress=plain --platform linux/arm/v7 --target build --no-cache --force-rm --compress --load -t qoopido/telerising.build:arm32v7 -f Dockerfile.build .
	docker buildx build --progress=plain --platform linux/arm/v6 --target build --no-cache --force-rm --compress --load -t qoopido/telerising.build:arm32v6 -f Dockerfile.build .
	docker create --name=telerising-amd64 --platform linux/amd64 qoopido/telerising.build:amd64
	docker create --name=telerising-arm64v8 --platform linux/arm64/v8 qoopido/telerising.build:arm64v8
	docker create --name=telerising-arm32v7 --platform linux/arm/v7 qoopido/telerising.build:arm32v7
	docker create --name=telerising-arm32v6 --platform linux/arm/v6 qoopido/telerising.build:arm32v6
	rm -rf ./binaries/*
	docker container cp telerising-amd64:/var/dist/ ./binaries/amd64
	docker container cp telerising-arm64v8:/var/dist/ ./binaries/arm64v8
	docker container cp telerising-arm32v7:/var/dist/ ./binaries/arm32v7
	docker container cp telerising-arm32v6:/var/dist/ ./binaries/arm32v6
	rm -rf ./binaries/**/settings.json
	tar -czvf ./binaries/telerising.amd64.tar.gz -C ./binaries/amd64 ./
	tar -czvf ./binaries/telerising.arm64v8.tar.gz -C ./binaries/arm64v8 ./
	tar -czvf ./binaries/telerising.arm32v7.tar.gz -C ./binaries/arm32v7 ./
	tar -czvf ./binaries/telerising.arm32v6.tar.gz -C ./binaries/arm32v6 ./
	rm -rf ./binaries/amd64 ./binaries/arm64v8 ./binaries/arm32v7 ./binaries/arm32v6
	docker buildx build --progress=plain --platform linux/amd64,linux/arm64,linux/arm/v7,linux/arm/v6 --target dist --compress --load -t qoopido/telerising.minimal:manual -f Dockerfile.build .

#############################
# Argument fix workaround
#############################
%:
	@:
