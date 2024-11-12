

## To create docker image
docker build -t crawler-chrome .

## To run docker and connect to remote selenium at the same host
docker run  --network="host" -it crawler-chrome

## To run docker and connect to remote selenium with URL
docker run -e REMOTE_SELENIUM="http://<remote url>>:4444/wd/hub" -it crawler-chrome 