.PHONY: all deploy run down

all:
	docker build -t p4km9y/hadoop-base:latest hadoop-base
	docker build -t p4km9y/hadoop-master:latest hadoop-master
	docker build -t p4km9y/hadoop-slave:latest hadoop-slave

deploy: all
	docker login
	docker push p4km9y/hadoop-master
	docker push p4km9y/hadoop-slave

run: all
	docker-compose up -d
	echo "http://localhost:9870 for HDFS"
	echo "http://localhost:8088 for YARN"

down:
	docker-compose down
