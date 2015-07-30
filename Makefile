##
## REFINE
##
REFINE_VERSION:=2.6-beta.1
REFINE_TARBALL:=openrefine-linux-$(REFINE_VERSION).tar.gz
REFINE_LOCATION:=https://github.com/OpenRefine/OpenRefine/releases/download/$(REFINE_VERSION)
REFINE_ROOT:=patched
REFINE_HOME=/var/refine
DOCKER_TAG:=tekii/refine:$(REFINE_VERSION)

##
## M4
##
M4= $(shell which m4)
M4_FLAGS= -P \
	-D __REFINE_VERSION__=$(REFINE_VERSION) \
	-D __REFINE_ROOT__=$(REFINE_ROOT) \
	-D __REFINE_HOME__=$(REFINE_HOME) \
	-D __DOCKER_TAG__=$(DOCKER_TAG)

$(REFINE_TARBALL):
	wget $(REFINE_LOCATION)/$(REFINE_TARBALL)
#	md5sum --check $(JDK_TARBALL).md5

$(REFINE_ROOT): $(REFINE_TARBALL) config.patch
	mkdir -p $@
	tar zxvf $(REFINE_TARBALL) -C $@ --strip-components=1
	patch -p0 -i config.patch

#.SECONDARY
Dockerfile: Dockerfile.m4 Makefile
	$(M4) $(M4_FLAGS) $< >$@


PHONY += update-patch
update-patch:
	diff -ruN original/ $(REFINE_ROOT)/  > config.patch; [ $$? -eq 1 ]

PHONY += image
image: $(REFINE_TARBALL) Dockerfile $(REFINE_ROOT)
	docker build -t $(DOCKER_TAG) .

PHONY+= run
run: #image
	docker run -p 3333:3333 -v $(shell pwd)/volume:$(REFINE_HOME) $(DOCKER_TAG)

PHONY+= push-to-docker
push-to-docker: image
	docker push $(DOCKER_TAG)

PHONY += push-to-google
push-to-google: image
	docker tag $(DOCKER_TAG) gcr.io/test-teky/refine:$(REFINE_VERSION)
	gcloud docker push gcr.io/test-teky/refine:$(REFINE_VERSION)

PHONY += clean
clean:
	rm -rf $(REFINE_ROOT)
	rm -f Dokerfile	

PHONY += realclean
realclean: clean
	rm -f $(REFINE_TARBALL)

PHONY += all
all: $(JDK_TARBALL)

.PHONY: $(PHONY)
.DEFAULT_GOAL := all
