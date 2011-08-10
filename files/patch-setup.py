--- setup.py.orig	2011-08-10 00:56:48.347491885 -0400
+++ setup.py	2011-08-10 00:56:50.051827849 -0400
@@ -3,6 +3,9 @@
 import os
 from glob import glob
 
+graphite_dbdir = '%%GRAPHITE_DBDIR%%' + '/'
+graphite_examplesdir = '%%EXAMPLESDIR%%' + '/'
+
 if os.environ.get('USE_SETUPTOOLS'):
   from setuptools import setup
   setup_kwargs = dict(zip_safe=0)
@@ -15,7 +18,7 @@
 storage_dirs = []
 
 for subdir in ('whisper', 'lists', 'rrd', 'log', 'log/webapp'):
-  storage_dirs.append( ('storage/%s' % subdir, []) )
+  storage_dirs.append( (graphite_dbdir + 'storage/%s' % subdir, []) )
 
 webapp_content = {}
 
@@ -29,7 +32,7 @@
     webapp_content[root].append(filepath)
 
 
-conf_files = [ ('conf', glob('conf/*.example')) ]
+conf_files = [ (graphite_examplesdir + 'conf', glob('conf/*.example')) ]
 
 setup(
   name='graphite-web',
