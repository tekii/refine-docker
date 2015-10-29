##
## REFINE
##
VERSION:=2.6-rc.2
TARBALL:=openrefine-linux-$(VERSION).tar.gz
LOCATION:=https://github.com/OpenRefine/OpenRefine/releases/download/$(VERSION)

REFINE_ROOT:=patched
INSTALL:=/opt/refine
HOME:=/var/refine
USER:=daemon
GROUP:=daemon

TAG:=tekii/refine:$(VERSION)
PROJECT_ID:=mrg-tky

##
## M4
##
M4= $(shell which m4)
M4_FLAGS= -P \
	-D __VERSION__=$(VERSION) \
	-D __LOCATION__=$(LOCATION) \
	-D __TARBALL__=$(TARBALL) \
	-D __INSTALL__=$(INSTALL) \
	-D __HOME__=$(HOME) \
	-D __USER__=$(USER) -D __GROUP__=$(GROUP)

$(TARBALL):
	wget $(LOCATION)/$@
#	md5sum --check $@.md5

original/: $(TARBALL)
	mkdir -p $@
	tar zxvf $(TARBALL) -C $@ --strip-components=1
patched/: $(TARBALL) config.patch
	mkdir -p $@
	tar zxvf $(TARBALL) -C $@ --strip-components=1
	patch -p0 -i config.patch

.PHONY: update-patch
update-patch: original/
	diff -ruN original/ patched/ > config.patch; [ $$? -eq 1 ]

.SECONDARY: Dockerfile
Dockerfile: Dockerfile.m4 Makefile
	$(M4) $(M4_FLAGS) $< >$@


.PHONY: image
image: Dockerfile config.patch
	docker build -t $(TAG) .

.PHONY: run
run: #image
	docker run -p 3333:3333 -v $(shell pwd)/volume:$(HOME) $(TAG)

.PHONY: push-to-google
push-to-google: image
	docker tag $(TAG) gcr.io/$(PROJECT_ID)/$(TAG)
	gcloud docker push gcr.io/$(PROJECT_ID)/$(TAG)

PHONY += git-tag git-push
git-tag:
	-git tag -d $(VERSION)
	git tag $(VERSION)

git-push:
	-git push origin :refs/tags/$(VERSION)
	git push origin
	git push --tags origin

.PHONY: clean realclean all
clean:
	rm -rf original/ patched/

realclean: clean
	rm -f $(REFINE_TARBALL)

all:

.DEFAULT_GOAL := all
