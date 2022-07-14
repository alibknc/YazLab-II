# Generated by Django 4.0.3 on 2022-03-15 12:17

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('dashboard', '0001_initial'),
    ]

    operations = [
        migrations.CreateModel(
            name='Location',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('lat', models.CharField(max_length=100, null=True)),
                ('lng', models.CharField(max_length=100, null=True)),
                ('date', models.CharField(max_length=100, null=True)),
                ('arac_id', models.IntegerField(null=True)),
            ],
        ),
        migrations.DeleteModel(
            name='File',
        ),
    ]
