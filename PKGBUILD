# Maintainer: Sam Stuewe <samuel dot stuewe at gmail dot com>

pkgname=hgweb-git
pkgver=0.r111.9543aee
pkgrel=1
pkgdesc='my website'
url='https://github.com/HalosGhost/halosgho.st'
arch=('i686' 'x86_64')
license=('GPL')
depends=('hitch' 'acme-client' 'lwan')
makedepends=('git')
source=('git+https://github.com/HalosGhost/halosgho.st.git')
sha256sums=('SKIP')

pkgver () {
    cd halosgho.st
    printf '0.r%s.%s' "$(git rev-list --count HEAD)" "$(git log -1 --pretty=format:%h)"
}

prepare () {
    cd halosgho.st
    ./configure
}

build () {
    cd halosgho.st
    make
}

package () {
    cd halosgho.st
    make DESTDIR="$pkgdir" install
}
