FROM golang:1.16

ENV GOARCH=amd64

# Get GCR credential helper
ADD https://github.com/GoogleCloudPlatform/docker-credential-gcr/releases/download/v2.0.1/docker-credential-gcr_linux_$GOARCH-2.0.1.tar.gz /usr/local/bin/
    RUN tar --no-same-owner -C /usr/local/bin/ -xvzf /usr/local/bin/docker-credential-gcr_linux_$GOARCH-2.0.1.tar.gz

# Get Amazon ECR credential helper
RUN (mkdir -p /go/src/github.com/awslabs || true)   && \
  cd /go/src/github.com/awslabs                                              && \
  git clone https://github.com/awslabs/amazon-ecr-credential-helper             && \
  cd  amazon-ecr-credential-helper                                                  && \
  make

# Azure docker env credential helper
RUN (mkdir -p /go/src/github.com/chrismellard || true)   && \
  cd /go/src/github.com/chrismellard                                              && \
  git clone https://github.com/chrismellard/docker-credential-acr-env             && \
  cd  docker-credential-acr-env                                                   && \
  make build

FROM gcr.io/projectsigstore/cosign:v0.3.1

COPY --from=0 /usr/local/bin/docker-credential-gcr /usr/bin/docker-credential-gcr
COPY --from=0 /go/src/github.com/awslabs/amazon-ecr-credential-helper/bin/local/docker-credential-ecr-login /usr/bin/docker-credential-ecr-login
COPY --from=0 /go/src/github.com/chrismellard/docker-credential-acr-env/build/docker-credential-acr-env /usr/bin/docker-credential-acr