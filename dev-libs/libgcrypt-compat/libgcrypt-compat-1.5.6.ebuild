# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools multilib-minimal

MY_PN="${PN%-compat}"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Old version of libgcrypt needed by some binaries"
HOMEPAGE="https://www.gnupg.org/"
SRC_URI="mirror://gnupg/${MY_PN}/${MY_P}.tar.bz2"
LICENSE="LGPL-2.1 MIT"
SLOT="11" # soname major version
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~m68k ~ppc ~ppc64 ~s390 ~sparc ~x86 ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x64-solaris"

RDEPEND=">=dev-libs/libgpg-error-1.12[${MULTILIB_USEDEP}]
	!dev-libs/libgcrypt:0/11
	!dev-libs/libgcrypt:11/11"

DEPEND="${RDEPEND}"

S="${WORKDIR}/${MY_P}"

PATCHES=(
	"${FILESDIR}"/${MY_PN}-1.5.0-uscore.patch
	"${FILESDIR}"/${MY_PN}-1.5.4-clang-arm.patch
)

src_prepare() {
	default
	eautoreconf
}

multilib_src_configure() {
	local myeconfargs=(
		--disable-padlock-support # bug 201917
		--enable-noexecstack
		--disable-O-flag-munging

		# disabled due to various applications requiring privileges
		# after libgcrypt drops them (bug #468616)
		--without-capabilities

		# http://trac.videolan.org/vlc/ticket/620
		$([[ ${CHOST} == *86*-darwin* ]] && echo "--disable-asm")
	)
	ECONF_SOURCE="${S}" econf "${myeconfargs[@]}"
}

multilib_src_install() {
	emake -C src DESTDIR="${D}" install-libLTLIBRARIES
	rm -vf "${ED}"/usr/$(get_libdir)/*.{la,so} || die
}
