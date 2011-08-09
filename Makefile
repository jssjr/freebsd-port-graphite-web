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
PYDISTUTILS_NOEGGINFO=	yes
PYDISTUTILS_INSTALLARGS+=	--install-data=${WWWDIR} \
				--install-lib=${WWWDIR}

FETCH_ARGS=	"-pRr"		# default '-AFpr' prevents 302 redirects by launchpad

RUN_DEPENDS+=   py-cairo:${PORTSDIR}/graphics/py-cairo \
		py-django:${PORTSDIR}/www/py-django \
		py-whisper:${PORTSDIR}/databases/py-whisper \
		py-carbon:${PORTSDIR}/net-mgmt/py-carbon

OPTIONS=	APACHE "Use apache as webserver" on \
		MODPYTHON3 "Enable mod_python3 support" off \
		MODWSGI3 "Enable mod_wsgi3 support" on

GRAPHITE_DBDIR?=	"/var/db/graphite"
GRAPHITE_LOGDIR?=	"/var/log/graphite"

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
	@${ECHO_MSG} "********************************************************************"
	@${ECHO_MSG} "Please note that this port overrides the default installation layout"
	@${ECHO_MSG} "for Graphite by modifying settings.py until the software is able to"
	@${ECHO_MSG} "configure its own layout."
	@${ECHO_MSG} "********************************************************************"

	@${REINPLACE_CMD} -e "s|^\(GRAPHITE_ROOT = \).*$|\1'${WWWDIR}' + '/'|" ${WRKSRC}/webapp/graphite/settings.py
	@${REINPLACE_CMD} -e "s|^\(WEBAPP_DIR = \).*$|\1''|" ${WRKSRC}/webapp/graphite/settings.py

	# XXX: REINPLACE THESE TOO!!
	#GRAPHITE_ROOT  = '${WWWDIR}' + '/'
	#WEBAPP_DIR     = GRAPHITE_ROOT + 'webapp/'
	#WEB_DIR        = WEBAPP_DIR + 'graphite/'
	#CONF_DIR       = '${ETCDIR}' + 'graphite/'
	#CONTENT_DIR    = WEBAPP_DIR + 'content/'
	#STORAGE_DIR    = '${GRAPHITE_DBDIR}' + 'graphite/'
	#WHISPER_DIR    = STORAGE_DIR + 'whisper/'
	#RRD_DIR        = STORAGE_DIR + 'rrd/'
	#LISTS_DIR      = STORAGE_DIR + 'lists/'
	#INDEX_FILE     = STORAGE_DIR + 'index'
	#WHITELIST_FILE = LISTS_DIR + 'whitelist'
	#LOG_DIR        = '${GRAPHITE_LOGDIR}' + 'graphite/'
	#THIRDPARTY_DIR = GRAPHITE_ROOT + 'thirdparty/'

post-install:
	cd ${GRAPHITE_BASE}/webapp && \
		${LN} -sf ../lib/graphite
	cd ${PREFIX}/bin && \
		${LN} -sf ${GRAPHITE_BASE}/bin/run-graphite-devel-server.py
# XXX Add exec call in plist to match

.include <bsd.port.mk>
