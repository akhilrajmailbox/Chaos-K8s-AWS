FROM akhilrajmailbox/ubuntu:16.04
MAINTAINER Akhil Raj <akhilrajmailbox@gmail.com>
RUN apt-get update \
    && apt-get install nano curl net-tools python-dev python-pip -y \
    && pip install awscli
WORKDIR /tmp/
RUN apt-get install jq -y
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl \
    && curl -o aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.11.5/2018-12-06/bin/linux/amd64/aws-iam-authenticator
RUN chmod +x kubectl \
    &&  chmod +x aws-iam-authenticator
RUN mv kubectl aws-iam-authenticator /usr/local/bin/
WORKDIR /
COPY docker_entrypoint.sh /
RUN chmod 100 /docker_entrypoint.sh