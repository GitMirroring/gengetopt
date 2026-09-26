# Copyright (C) 1999-2007  Free Software Foundation, Inc.
#
# This file is part of GNU gengetopt
#
# GNU gengetopt is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3, or (at your option)
# any later version.
#
# GNU gengetopt is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
# Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with gengetopt; see the file COPYING. If not, see <http://www.gnu.org/licenses/>.

ACLOCAL_AMFLAGS = -I m4 -I gl/m4

EXTRA_DIST = configure TODO LICENSE gl/m4/gnulib-cache.m4
SUBDIRS = gl src tests

if ENABLE_DOC
SUBDIRS += doc
endif

# This does not work if placed into doc/Makefile.am.  Hm.
AM_DISTCHECK_DVI_TARGET = html

gengetoptdoc_DATA = ChangeLog COPYING NEWS THANKS INSTALL README LICENSE

TARBALL = $(top_builddir)/gengetopt-$(PACKAGE_VERSION).tar.xz

release:
	$(MAKE) $(AM_MAKEFLAGS)
	$(MAKE) $(AM_MAKEFLAGS) check
	$(MAKE) $(AM_MAKEFLAGS) dist
	cp $(top_srcdir)/gengetopt.directive $(TARBALL).directive
	sed -i -e 's/VERSION/$(PACKAGE_VERSION)/g' $(TARBALL).directive
	gpg --yes --detach-sign $(TARBALL)
	gpg --yes --clear-sign $(TARBALL).directive
	curl -T $(TARBALL)               ftp://ftp-upload.gnu.org/incoming/ftp/
	curl -T $(TARBALL).sig           ftp://ftp-upload.gnu.org/incoming/ftp/
	curl -T $(TARBALL).directive.asc ftp://ftp-upload.gnu.org/incoming/ftp/
	@echo
	@echo 'Do not forget to update the website!'
	@echo 'https://www.gnu.org/prep/maintain/maintain.html#Web-Pages'
	@echo

ChangeLog:
	fmt='__-tag-line-__%>|(78)%(decorate:tag=)%n%as  %aN  <%aE>%n%n%w(0,8,8)%B'; \
	git -C '$(abs_top_srcdir)' log						     \
		--decorate-refs 'refs/tags/v*'					     \
		--format="$$fmt"						     \
		--no-merges --no-color HEAD >$@.x

	$(AWK) '/^__-tag-line-__[\t ]*$$/ {next}{print}' <$@.x >$@.y
	mv $@.y $@.x

	$(SED) 's/^__-tag-line-__/              /'       <$@.x >$@.y
	mv $@.y $@.x

	$(SED) 's/^ \+$$//'                              <$@.x >$@.y
	mv $@.y $@.x

	mv $@.x $@
