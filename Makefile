GUT_BINARY=dev
UNAME_S=$(shell uname -s | tr [:upper:] [:lower:])
UNAME_M=$(shell uname -m)
GOOS ?= $(UNAME_S)
VERSION ?= latest

ifeq ($(UNAME_M),i386)
  GOARCH ?= 386
endif
ifeq ($(UNAME_M),x86_64)
  GOARCH ?= amd64
endif

ifeq ($(GOARCH),386)
  ARCH=i386
endif
ifeq ($(GOARCH),amd64)
  ARCH=x86_64
endif

ifeq ($(GOOS),linux)
  OS=Linux
endif
ifeq ($(GOOS),darwin)
  OS=Darwin
endif

all: dev

dev: gut_build.go config.go deps.go gut_build.go gut_cmd.go shell.go sync_context.go util.go
	go build -o release/${OS}/${ARCH}/bin/${GUT_BINARY} 

install:
	cp release/${OS}/${ARCH}/bin/${GUT_BINARY} /usr/local/bin/${GUT_BINARY}

uninstall:
	rm /usr/local/bin/${GUT_BINARY}

clean:
	rm -rf release

package: dev
	cd release/${OS}/${ARCH} && tar -czvf ${GUT_BINARY}.tgz --exclude=${GUT_BINARY}.tgz --exclude=gut-2.5.0.tgz . 

publish: package
	aws --region us-west-1 s3 cp release/${OS}/${ARCH}/${GUT_BINARY}.tgz s3://get.dupper.co/dev/${OS}/${ARCH}/${GUT_BINARY}-${VERSION}.tgz --acl public-read

get-deps: 
	wget -O release/Linux/x86_64/gut-2.5.0.tgz https://www.tillberg.us/c/d437b2008d313974b4b5a4293bcf93b8b681e65919c74099e6016975387d7eae/gut-linux-2.5.0.tgz
	wget -O release/Darwin/x86_64/gut-2.5.0.tgz https://www.tillberg.us/c/2cbf485213af3061a3d5ce27211295ae804d535ed4854f9da6d57418bcc39424/gut-darwin-2.5.0.tgz

publish-deps: release/Linux/x86_64/gut-2.5.0.tgz release/Darwin/x86_64/gut-2.5.0.tgz
	aws --region us-west-1 s3 cp release/Linux/x86_64/gut-2.5.0.tgz s3://get.dupper.co/dev/Linux/x86_64/gut-2.5.0.tgz --acl public-read
	aws --region us-west-1 s3 cp release/Darwin/x86_64/gut-2.5.0.tgz s3://get.dupper.co/dev/Darwin/Linux/x86_64/gut-2.5.0.tgz --acl public-read

publish-install-script: install.sh
	aws --region us-west-1 s3 cp --acl public-read --content-type 'text/plain' ./install.sh s3://get.dupper.co/dev/index 

