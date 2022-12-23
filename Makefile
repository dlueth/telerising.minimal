ARGS = $(filter-out $@,$(MAKECMDGOALS))
MAKEFLAGS += --silent

clean:
	rm -rf ./binaries/*
	docker stop telerising
	docker rm telerising

build:
	docker buildx build --build-arg TAR=true --platform linux/amd64 --no-cache --compress --load -t qoopido/telerising.minimal:latest .
	docker create --name=telerising --platform linux/amd64 qoopido/telerising.minimal:latest
	docker container cp telerising:/telerising.amd64.tar.gz ./binaries
	docker rm telerising
	docker buildx build --build-arg TAR=true --platform linux/arm64 --no-cache --compress --load -t qoopido/telerising.minimal:latest .
	docker create --name=telerising --platform linux/arm64 qoopido/telerising.minimal:latest
	docker container cp telerising:/telerising.arm64.tar.gz ./binaries
	docker rm telerising
	docker buildx build --build-arg TAR=true --platform linux/arm/v7 --no-cache --compress --load -t qoopido/telerising.minimal:latest .
	docker create --name=telerising --platform linux/arm/v7 qoopido/telerising.minimal:latest
	docker container cp telerising:/telerising.arm.tar.gz ./binaries
	docker rm telerising
	docker buildx build --platform linux/amd64,linux/arm64,linux/arm/v7 --compress --push -t qoopido/telerising.minimal:latest .


#############################
# Argument fix workaround
#############################
%:
	@:
