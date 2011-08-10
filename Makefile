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

RUN_DEPENDS+=   ${PYTHON_LIBDIR}/site-packages/cairo/__init__.py:${PORTSDIR}/graphics/py-cairo \
                ${PYTHON_LIBDIR}/site-packages/django/__init__.py:${PORTSDIR}/www/py-django \
		${PYTHON_LIBDIR}/site-packages/whisper.py:${PORTSDIR}/databases/py-whisper

OPTIONS=	APACHE "Use apache as webserver" on \
		CARBON "Build carbon backend " on \
		MODPYTHON3 "Enable mod_python3 support" off \
		MODWSGI3 "Enable mod_wsgi3 support" on

GRAPHITE_DBDIR?=	"/var/db/graphite"
GRAPHITE_LOGDIR?=	"/var/log/graphite"

.include <bsd.port.options.mk>

.if defined (WITH_CARBON)
RUN_DEPENDS+=	${PYTHON_LIBDIR}/site-packages/carbon/__init__.py:${PORTSDIR}/net-mgmt/py-carbon
.endif

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
	@${RM} -f ${WRKSRC}/setup.cfg
	@${REINPLACE_CMD} -e "s|/opt/graphite|${GRAPHITE_BASE}|g" ${WRKSRC}/conf/graphite.wsgi.example
	@${REINPLACE_CMD} -e "s|/opt/graphite|${GRAPHITE_BASE}|g" ${WRKSRC}/examples/example-graphite-vhost.conf
	@${ECHO_MSG} "********************************************************************"
	@${ECHO_MSG} "Please note that this port overrides the default installation layout"
	@${ECHO_MSG} "for Graphite by modifying settings.py until the software is able to"
	@${ECHO_MSG} "configure its own layout."
	@${ECHO_MSG} "********************************************************************"

	@${REINPLACE_CMD} -e "s|^\(GRAPHITE_ROOT = \).*|\1'${WWWDIR}/'|" \
		-e "s|^\(WEBAPP_DIR = \).*|\1GRAPHITE_ROOT + 'webapp/'|" \
		-e "s|^\(WEB_DIR = \).*|\1WEBAPP_DIR + 'graphite/'|" \
		-e "s|^\(CONF_DIR = \).*|\1'${ETCDIR}/graphite/'|" \
		-e "s|^\(CONTENT_DIR = \).*|\1WEBAPP_DIR + 'content/'|" \
		-e "s|^\(STORAGE_DIR = \).*|\1'${GRAPHITE_DBDIR}/graphite/'|" \
		-e "s|^\(LOG_DIR = \).*|\1'${GRAPHITE_LOGDIR}/graphite/'|" \
		-e "s|^\(THIRDPARTY_DIR = \).*|\1GRAPHITE_ROOT + 'thirdparty/'|" ${WRKSRC}/webapp/graphite/settings.py
	
	@${REINPLACE_CMD} -e "s|%%GRAPHITE_DBDIR%%|${GRAPHITE_DBDIR}|g" \
		-e "s|%%EXAMPLESDIR%%|${EXAMPLESDIR}|g" ${WRKSRC}/setup.py

.include <bsd.port.mk>
