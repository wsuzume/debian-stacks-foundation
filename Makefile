build: DOCKER_BUILD_ARGS?=
build: TAG?=
build:
	docker image build --rm --force-rm $(DOCKER_BUILD_ARGS) -t ${TAG} .

sudo_build: DOCKER_BUILD_ARGS?=
sudo_build: TAG?=
sudo_build:
	sudo docker image build --rm --force-rm $(DOCKER_BUILD_ARGS) -t ${TAG} .