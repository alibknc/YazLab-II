from django.urls import path
from . import views

urlpatterns = [
    path('home/', views.home_view, name='home'),
    path('table/', views.Table, name='table'),
    path('logout/', views.logOut, name='logout'),
]