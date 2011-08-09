# New ports collection makefile for:	graphite-web
# Date created:		2011-07-22
# Whom:			Scott Sanders <ssanders@taximagic.com>
#
# $FreeBSD$
#

PORTNAME=	graphite-web
PORTVERSION=	0.9.8
CATEGORIES=	net-mgmt python
MASTER_SITES=	http://launchpad.net/graphite/1.0/${PORTVERSION}/+download/
PKGNAMEPREFIX=	${PYTHON_PKGNAMEPREFIX}

MAINTAINER=	ssanders@taximagic.com
COMMENT=	Graphite is a highly scalable real-time graphing system

LICENSE=	ASL

MAKE_JOBS_SAFE=	yes

USE_PYTHON=	2.4+
USE_PYDISTUTILS=yes

FETCH_ARGS=	"-pRr"		# default '-AFpr' prevents 302 redirects by launchpad

RUN_DEPENDS+=   py-cairo:${PORTSDIR}/graphics/py-cairo \
		py-django:${PORTSDIR}/www/py-django \
		py-whisper:${PORTSDIR}/databases/py-whisper \
		py-carbon:${PORTSDIR}/net-mgmt/py-carbon

OPTIONS=	APACHE "Use apache as webserver" on \
		MODPYTHON3 "Enable mod_python3 support" off \
		MODWSGI3 "Enable mod_wsgi3 support" on

PYDISTUTILS_NOEGGINFO=	yes
GRAPHITE_DIR=	graphite
GRAPHITE_BASE=	${PREFIX}/${GRAPHITE_DIR}
PLIST_SUB=	GRAPHITE_BASE=${GRAPHITE_DIR}
PYDISTUTILS_INSTALLARGS+=	--install-data=${GRAPHITE_BASE} \
				--install-lib=${GRAPHITE_BASE}/lib  \
				--install-scripts=${GRAPHITE_BASE}/bin

.include <bsd.port.options.mk>

.if defined (WITH_APACHE)
USE_APACHE_RUN= 2.0+
.endif

.if defined(WITH_MODPYTHON3)
RUN_DEPENDS+=   ${LOCALBASE}/${APACHEMODDIR}/mod_python.so:${PORTSDIR}/www/mod_python3
.endif

.if defined(WITH_MODWSGI3)
RUN_DEPENDS+=   ${LOCALBASE}/${APACHEMODDIR}/mod_wsgi.so:${PORTSDIR}/www/mod_wsgi3
.endif

.if defined(WITH_MODPYTHON3) && !defined(WITH_APACHE)
IGNORE=	"mod_python3 needs Apache, please select Apache"
.endif

.if defined(WITH_MODWSGI3) && !defined(WITH_APACHE)
IGNORE=	"mod_wsgi3 needs Apache, please select Apache"
.endif

post-patch:
	${RM} -f ${WRKSRC}/setup.cfg
	@${REINPLACE_CMD} -e "s|/opt/graphite|${GRAPHITE_BASE}|g" ${WRKSRC}/conf/graphite.wsgi.example
	@${REINPLACE_CMD} -e "s|/opt/graphite|${GRAPHITE_BASE}|g" ${WRKSRC}/examples/example-graphite-vhost.conf

post-install:
	cd ${GRAPHITE_BASE}/webapp && \
		${LN} -sf ../lib/graphite
	cd ${PREFIX}/bin && \
		${LN} -sf ${GRAPHITE_BASE}/bin/run-graphite-devel-server.py
# XXX Add exec call in plist to match

.include <bsd.port.mk>
