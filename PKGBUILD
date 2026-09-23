# Maintainer: cwee <2gbleh@gmail.com>

pkgname=ticktick-cli-apparmor
_appname=ticktick-cli
_npmname=@ticktick/ticktick-cli
pkgver=0.1.14
pkgrel=1
pkgdesc='Command-line interface for TickTick, running on bun under AppArmor confinement'
arch=('any')
url='https://www.npmjs.com/package/@ticktick/ticktick-cli'
license=('MIT')
# bun replaces node as the runtime; aa-exec comes from apparmor; xdg-open is
# needed by `ticktick auth login` to open the OAuth consent page.
depends=('bun' 'apparmor' 'xdg-utils')
makedepends=('npm')
provides=("$_appname=$pkgver")
conflicts=("$_appname")
install="$pkgname.install"

# Upstream's git repo (github.com/TickTeam/ticktick-cli) is not publicly
# accessible, so the npm registry tarball is the only available source. It
# ships a prebuilt dist/ tree, hence there is nothing to compile here; build()
# only resolves the runtime dependencies into a staging prefix.
source=("$_appname-$pkgver.tgz::https://registry.npmjs.org/${_npmname}/-/${_appname}-${pkgver}.tgz"
        'ticktick.sh'
        'ticktick-cli.apparmor'
        'ticktick-cli-common.apparmor')
noextract=("$_appname-$pkgver.tgz")
sha256sums=('f1ad1ce39ef7299f1f8d499f43e3ef390882dcf0b02c05de6e4e18e15053d960'
            '8bb1d2db56fb6ea7a0aa7378dd85452279c736744841b1bf6cd5358aac729576'
            '4980f7e1b8cb398da1ef8c65f675463821092de59432a1a842328f2c16c07fae'
            '941e0061eeb2871a54dabd82de639cd3723948672c32701fc6712917318e2032')

build() {
	# Install into a staging prefix at build time so that package() is offline.
	# --install-links materialises deps as real directories instead of symlinks
	# into the npm cache, which would dangle inside the package.
	npm install --global --omit=dev --install-links --no-fund --no-audit \
		--cache "$srcdir/npm-cache" \
		--prefix "$srcdir/staging/usr" \
		"$srcdir/$_appname-$pkgver.tgz"
}

package() {
	local _moddir="usr/lib/node_modules/${_npmname}"

	install -d "$pkgdir/usr/lib/node_modules/@ticktick"
	cp -a "$srcdir/staging/$_moddir" "$pkgdir/$_moddir"

	# The bundled 'open' dependency ships its own copy of xdg-open and prefers
	# it over the system one whenever it is executable. Drop the executable bit
	# so it falls back to /usr/bin/xdg-open from xdg-utils: that keeps the
	# browser hand-off on the distro's version and lets the AppArmor profile
	# grant exactly one exec path instead of two.
	chmod -x "$pkgdir/$_moddir/node_modules/open/xdg-open"

	# npm honours the build user's umask, which can leave group/world-unreadable
	# paths in the package. 'X' keeps the executable bit only where npm already
	# set it (directories and dist/index.js).
	chmod -R u=rwX,go=rX "$pkgdir/usr"

	# /usr/bin/ticktick is the only entry point: it picks one of the two
	# AppArmor profiles based on the subcommand and then hands the script to
	# bun. dist/index.js keeps a node shebang from
	# upstream, so it is installed non-executable to make clear it is not meant
	# to be run directly.
	chmod -x "$pkgdir/$_moddir/dist/index.js"
	install -Dm755 "$srcdir/ticktick.sh" "$pkgdir/usr/bin/ticktick"
	ln -s ticktick "$pkgdir/usr/bin/${_appname}"

	install -Dm644 "$srcdir/ticktick-cli.apparmor" "$pkgdir/etc/apparmor.d/ticktick-cli"
	install -Dm644 "$srcdir/ticktick-cli-common.apparmor" \
		"$pkgdir/etc/apparmor.d/abstractions/ticktick-cli"

	install -Dm644 "$srcdir/staging/$_moddir/README.md" \
		-t "$pkgdir/usr/share/doc/$pkgname"

	# NOTE: upstream publishes under MIT (per package.json) but ships no license
	# text in the npm tarball and has no public repo to take one from, so there
	# is nothing to install into /usr/share/licenses. namcap will warn about it.
}
