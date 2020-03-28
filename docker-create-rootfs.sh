docker image build -t archl4tbuild:1.0 .
docker container run --privileged --rm -i -t --name archl4tbuild archl4tbuild:1.0