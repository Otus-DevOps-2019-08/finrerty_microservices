USERNAME = finrerty

build_all: build_prometheus \
			build_comment \
			build_post-py \
			build_ui \
			build_alertmanager

build_prometheus:
	cd monitoring/prometheus && docker build -t finrerty/prometheus .

build_comment:
	export USER_NAME=finrerty && cd src/comment && bash docker_build.sh

build_post-py:
	export USER_NAME=finrerty && cd src/post-py && bash docker_build.sh

build_ui:
	export USER_NAME=finrerty && cd src/ui && bash docker_build.sh

build_alertmanager:
	cd monitoring/alertmanager && docker build -t finrerty/alertmanager .


push_all: push_prometheus \
			push_comment \
			push_post_py \
			push_ui \
			push_alertmanager

push_prometheus: build_prometheus 
	docker push $(USERNAME)/prometheus:latest

push_comment: build_comment
	docker push $(USERNAME)/comment:latest

push_post_py: build_post-py
	docker push $(USERNAME)/post:latest

push_ui: build_ui
	docker push $(USERNAME)/ui:latest

push_alertmanager: build_alertmanager
	docker push $(USERNAME)/alertmanager:latest
