#!/bin/sh
exec aa-exec -p ticktick-cli -- bun /usr/lib/node_modules/@ticktick/ticktick-cli/dist/index.js "$@"
