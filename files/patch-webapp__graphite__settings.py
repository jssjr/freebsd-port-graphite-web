--- webapp/graphite/settings.py.orig	2011-04-01 19:48:43.000000000 +0000
+++ webapp/graphite/settings.py	2011-09-27 20:38:22.000000000 +0000
@@ -20,9 +20,9 @@
 JAVASCRIPT_DEBUG = False
 
 # Filesystem layout (all directores should end in a /)
-WEB_DIR = dirname( abspath(__file__) ) + '/'
-WEBAPP_DIR = dirname( dirname(WEB_DIR) ) + '/'
 GRAPHITE_ROOT = dirname( dirname(WEBAPP_DIR) ) + '/'
+WEBAPP_DIR = dirname( dirname(WEB_DIR) ) + '/'
+WEB_DIR = dirname( abspath(__file__) ) + '/'
 CONF_DIR = GRAPHITE_ROOT + 'conf/'
 CONTENT_DIR = WEBAPP_DIR + 'content/'
 STORAGE_DIR = GRAPHITE_ROOT + 'storage/'
