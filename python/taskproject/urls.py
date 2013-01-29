from django.conf.urls import patterns, include, url
from django.contrib.staticfiles.urls import staticfiles_urlpatterns
from taskapp.views import deleteTask

# Uncomment the next two lines to enable the admin:
# from django.contrib import admin
# admin.autodiscover()

urlpatterns = patterns('',
    # Examples:
    # url(r'^$', 'tasklist.views.home', name='home'),
    # url(r'^tasklist/', include('tasklist.foo.urls')),

    # Uncomment the admin/doc line below to enable admin documentation:
    # url(r'^admin/doc/', include('django.contrib.admindocs.urls')),

    # Uncomment the next line to enable the admin:
    # url(r'^admin/', include(admin.site.urls)),
	
    url(r'^$', 'taskapp.views.index'),
    url(r'^delete/(?P<taskId>.+)', 'taskapp.views.deleteTask'),
    url(r'^complete/(?P<taskId>.+)/(?P<isComplete>.+)', 'taskapp.views.markComplete'),
)

urlpatterns += staticfiles_urlpatterns()

