# Maintainer: cwee <2gbleh@gmail.com>

pkgname=ticktick-cli
_npmname=@ticktick/ticktick-cli
pkgver=0.1.14
pkgrel=1
pkgdesc='Command-line interface for TickTick'
arch=('any')
url='https://www.npmjs.com/package/@ticktick/ticktick-cli'
license=('MIT')
depends=('nodejs')
makedepends=('npm')

# Upstream's git repo (github.com/TickTeam/ticktick-cli) is not publicly
# accessible, so the npm registry tarball is the only available source. It
# ships a prebuilt dist/ tree, hence there is nothing to compile here; build()
# only resolves the runtime dependencies into a staging prefix.
source=("$pkgname-$pkgver.tgz::https://registry.npmjs.org/${_npmname}/-/${pkgname}-${pkgver}.tgz")
noextract=("$pkgname-$pkgver.tgz")
sha256sums=('f1ad1ce39ef7299f1f8d499f43e3ef390882dcf0b02c05de6e4e18e15053d960')

build() {
	# Install into a staging prefix at build time so that package() is offline.
	# --install-links materialises deps as real directories instead of symlinks
	# into the npm cache, which would dangle inside the package.
	npm install --global --omit=dev --install-links --no-fund --no-audit \
		--cache "$srcdir/npm-cache" \
		--prefix "$srcdir/staging/usr" \
		"$srcdir/$pkgname-$pkgver.tgz"
}

package() {
	cp -a "$srcdir/staging/usr" "$pkgdir/usr"

	# npm leaves its own bookkeeping behind; it does not belong in the package.
	rm -f "$pkgdir/usr/lib/node_modules/.package-lock.json"

	# npm honours the build user's umask, which can leave group/world-unreadable
	# paths in the package. 'X' keeps the executable bit only where npm already
	# set it (directories, dist/index.js, dependency helper scripts).
	chmod -R u=rwX,go=rX "$pkgdir/usr"

	install -Dm644 "$srcdir/staging/usr/lib/node_modules/${_npmname}/README.md" \
		-t "$pkgdir/usr/share/doc/$pkgname"

	# NOTE: upstream publishes under MIT (per package.json) but ships no license
	# text in the npm tarball and has no public repo to take one from, so there
	# is nothing to install into /usr/share/licenses. namcap will warn about it.
}
