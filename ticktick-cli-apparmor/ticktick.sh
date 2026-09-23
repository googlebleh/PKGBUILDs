#!/bin/sh
# `ticktick auth login` is the only subcommand that opens a browser and binds
# the OAuth callback listener, so it gets the looser profile. Everything else
# -- including `auth token`, `auth status` and `auth logout` -- runs under the
# everyday profile, which can neither exec a program nor open a port.
#
# The match is on the first two positional arguments only, so that something
# like `ticktick task create --title "auth login"` is not mistaken for it.
if [ "$1" = auth ] && [ "$2" = login ]; then
	_profile=ticktick-cli-login
else
	_profile=ticktick-cli
fi

exec aa-exec -p "$_profile" -- \
	bun /usr/lib/node_modules/@ticktick/ticktick-cli/dist/index.js "$@"
