from operator import mod
from django.db import models
from django.contrib.auth.models import User

class Musteri(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    giris = models.DateTimeField(max_length=100, null=True)
    cikis= models.DateTimeField(max_length=100, null=True)
    arac1 = models.IntegerField(max_length=100, null=True)
    arac2 = models.IntegerField(max_length=100, null=True)