## Run selenium/standalone-chrome
docker run -d -p 4444:4444 -p 7900:7900 --shm-size="2g" selenium/standalone-chrome:latest

## To create docker image
docker build -t crawler-chrome .

## To run docker and connect to remote selenium at the same host and Run test browsing web page
docker run  --rm --network="host" -it crawler-chrome

## Run test to browse web page
python /app/crawler_chrome/app.py

## To run docker and connect to remote selenium with URL
docker run -e REMOTE_SELENIUM="http://<remote url>:4444/wd/hub" -it crawler-chrome 

## deploy to AWS
cd terraform
terraform init
terraform plan
terraform apply

## push to ECR (after treeaform apply)
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin 602843233966.dkr.ecr.us-west-2.amazonaws.com
docker tag crawler-chrome:latest 602843233966.dkr.ecr.us-west-2.amazonaws.com/crawler-chrome:latest
docker push 602843233966.dkr.ecr.us-west-2.amazonaws.com/crawler-chrome:latest