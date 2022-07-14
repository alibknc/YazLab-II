from django.db import models
from django.contrib.auth.models import User

class Location(models.Model):
    lat = models.CharField(max_length=100, null=True)
    lng = models.CharField(max_length=100, null=True)
    date = models.CharField(max_length=100, null=True)
    arac_id = models.IntegerField(null=True)

    def __str__(self):
        return self.id

    def delete(self, *args, **kwargs):
        super().delete(*args, **kwargs)

    

