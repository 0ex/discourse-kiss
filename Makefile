
VER=$(shell git describe --tags)
TAG=0ex0/discourse-kiss:latest
TAG2=0ex0/discourse-kiss:${VER}

deploy:
	docker build -t ${TAG} .
	docker tag ${TAG} ${TAG2}
	docker push ${TAG}
	docker push ${TAG2}
