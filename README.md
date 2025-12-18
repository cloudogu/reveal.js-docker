![](https://cloudogu.com/assets/blog/2019/revealJS-711db5dd3e495fe26dda7ad44104542b1fceb456c11700a773a2f158bf2c8251.png)

reveal.js-docker
===

[![Build Status](https://oss.cloudogu.com/jenkins/buildStatus/icon?job=cloudogu-github%2Freveal.js-docker%2Fmaster)](https://oss.cloudogu.com/jenkins/job/cloudogu-github/job/reveal.js-docker/job/master/)
[![](https://img.shields.io/docker/image-size/cloudogu/reveal.js)](https://hub.docker.com/r/cloudogu/reveal.js)

Docker images providing easier to use, opinionated reveal.js web apps - web-based slides/presentations. 
See [example presentation](https://cloudogu.github.io/reveal.js-docker-example) for a showcase of all features.

Evolution of [cloudogu/continuous-delivery-slides](https://github.com/cloudogu/continuous-delivery-slides).
Allows for 
* less cluttered Repos (more slides, less reveal.js)
* faster startup / builds (don't have to build reveal.js over and over again)
* easier updates (new version of docker image; no git merge necessary)

# Table of contents

<!-- Update with `doctoc --notitle README.md`. See https://github.com/thlorenz/doctoc -->
<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->


- [How to use](#how-to-use)
  - [Simplest start](#simplest-start)
  - [Ship your own slides](#ship-your-own-slides)
    - [Further options](#further-options)
    - [Running/Building containers](#runningbuilding-containers)
  - [Index.html pseudo-template](#indexhtml-pseudo-template)
  - [Examples](#examples)
- [Development](#development)
  - [Tests](#tests)
  - [Docker Image](#docker-image)
  - [Script templateIndexHtml](#script-templateindexhtml)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


# How to use

## Simplest start 

Ships a default presentation:

```bash
docker run --rm -p 8080:8080 cloudogu/reveal.js
```

Presentation is served at http://localhost:8080

## Ship your own slides

Have a look at the [reveal.js-docker-example](https://github.com/cloudogu/reveal.js-docker-example).

In a nutshell, just 

* mount your markdown slides to `/reveal/docs/slides`, e.g.  
  `-v $(pwd)/docs/slides:/reveal/docs/slides` and
* start container (see [bellow](#runningbuilding-containers))  
  \- there is also a variant with live-reloading for 
  efficient slide creation.

See also [examples](#examples).

### More options

See [index.html pseudo-template](#indexhtml-pseudo-template) to see the effects of the options.

* Mount additional folders to web server, e.g. like so:  
 `-v $(pwd)/images:/reveal/images`
* Mount folder containing HTML fragment files ([examples](scripts/test/)) to `/resources`
  * `slides.html` ➡️ Customize slides from `docs/slides` ([example](scripts/test/slides.html)).  
     Useful if you want to hide slides from printing.
  * `additional.js` - script executed before initializing reveal.js
  * `body-end.html` - `html` injected at the end of HTML `<body>`
  * `footer.html`, `header-left.html`, `header-right.html` - rendered at the footer (lower left corner) or header (upper left/right corner)
* Optional Env vars: *Note: Make sure to use single quotes*, otherwise parsing in `startPresentation.sh` from [example](https://github.com/cloudogu/reveal.js-docker-example) will fail
  * `TITLE='my title'`
  * `THEME_CSS`
     * `cloudogu.css`
     * `cloudogu-black.css`
     * [reveal.js themes](https://github.com/hakimel/reveal.js/#theming)
  * `WIDTH`, `HEIGHT`, `MARGIN`, `MIN_SCALE`, `MAX_SCALE` - [presentation size](https://revealjs.com/presentation-size/)
  * `SHOW_NOTES_FOR_PRINTING` - print speaker notes - defaults to `false`.
  * `ADDITIONAL_REVEAL_OPTIONS` - [additional reveal.js options](https://revealjs.com/config/)
  * `ADDITIONAL_PLUGINS` - additional reveal.js plugins.
     * e.g. `-e ADDITIONAL_PLUGINS="RevealMath" `
     * Add the plugin script using `ADDITIONAL_SCRIPT`, e.g. `-e ADDITIONAL_SCRIPT='<script src="plugin/math/math.js"></script>'`  
     * TODO legacy plugins
     * External plugins have to be mounted or copied to the `/reveal` folder, e.g. here  
     `-v $(pwd)/plugin/tagcloud:/reveal/plugin/tagcloud`
  * `SKIP_TEMPLATING` ignores all of the above elements and just launches with the `index.html` present.  
     Useful when mounting your own `index.html`.

### Running/Building containers 

Note that [reveal.js-docker-example](https://github.com/cloudogu/reveal.js-docker-example) also contains a convenient
 startup script.

```bash
# Development mode (with live reloading for editing the slides)
docker run --rm \
    -v $(pwd)/docs/slides:/reveal/docs/slides \
    -v $(pwd)/scripts/test:/resources \
    -e TITLE='my Title' -e THEME_CSS='cloudogu-black.css' \
    -p 8000:8000 -p 35729:35729 \
    cloudogu/reveal.js:dev

# Production Mode (smaller, more secure, just a static HTML site served by NGINX)
docker run --rm \
    -v $(pwd)/docs/slides:/reveal/docs/slides \
    -v $(pwd)/scripts/test:/resources \
    -e TITLE='my Title' -e THEME_CSS='cloudogu-black.css' \
    -p 8080:8080 \
    cloudogu/reveal.js
```

You can also build your own productive image:

```Dockerfile
FROM cloudogu/reveal.js:4.0.2-r3 as base

FROM base as aggregator
USER root
RUN mkdir -p /dist/reveal
COPY . /dist/reveal
RUN mv /dist/reveal/resources/ /dist

FROM base
ENV TITLE='my Title' \
    THEME_CSS='cloudogu-black.css'
COPY --from=aggregator --chown=nginx /dist /
```

Or if you want to run the container with `--read-only` file system, you can do the index.html rendering at build time,
so no files need to be written at runtime:

```Dockerfile
FROM cloudogu/reveal.js:4.0.2-r3 as base

FROM base as aggregator
ENV TITLE='myTitle' \
    THEME_CSS='cloudogu-black.css'
USER root
COPY . /reveal
RUN mv /reveal/resources/ /
RUN /scripts/templateIndexHtml

FROM base
ENV SKIP_TEMPLATING='true'
COPY --from=aggregator --chown=nginx /reveal /reveal
```

You can then start your container like so

```bash
docker run --rm -u 1000000:1000000 --read-only -v someTempFileImage:/tmp yourImageName
```

## Index.html pseudo-template

See [index.html](index.html)

## Examples

* [cloudogu/reveal.js-docker-example](https://github.com/cloudogu/reveal.js-docker-example)

Real Life:

* [cloudogu/gitops-talks](https://github.com/cloudogu/gitops-talks)
* [cloudogu/k8s-appops-security-talks](https://github.com/cloudogu/k8s-appops-security-talks)
* [cloudogu/k8s-intro-talk](https://github.com/cloudogu/k8s-intro-talk)

# Development

Build Docker Images, from repo root

```bash
docker build -t cloudogu/reveal.js:local  --progress=plain .
docker build -t cloudogu/reveal.js:local-dev --build-arg ENV=dev  --progress=plain .
```

Note: If only one build is required, buildkit would be more efficient. However, prod is failing with buildkit.
Try it with `export DOCKER_BUILDKIT=0` See [this issue](https://github.com/moby/moby/issues/735)

## Upgrading from upstream reveal.js

```shell
git remote add upstream https://github.com/hakimel/reveal.js
git fetch upstream --tags
git merge 5.2.1
# Fix merge conflicts.
# index.html because of templating 
# README -> README-reveal-js.md
# Because of tweemoji and font-awesome,
# resolve gulpfile.js and package.json
# run npm install to get proper package-lock.json
# Build Docker images and test both images variants (e.g. with cloudogu/reveal.js-docker-example)
git tag -s 5.2.1-r1
git push --follow-tags
```

## Tests

## Docker Image

Build (as described [here](#development)) and run container as described [here](#ship-your-own-slides).

## Script templateIndexHtml

Test script locally (manually for now 😬)

```bash
# For now manually
CAT_INDEX_HTML='true' RESOURCE_FOLDER='scripts/test' WEB_FOLDER='.' scripts/src/templateIndexHtml
```
