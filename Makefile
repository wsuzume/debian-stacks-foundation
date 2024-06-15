build: DOCKER_BUILD_ARGS?=
build: TAG?=
build:
	sudo docker image build --rm --force-rm $(DOCKER_BUILD_ARGS) -t ${TAG} .
