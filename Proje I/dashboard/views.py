from asyncio.windows_events import NULL
import csv
from datetime import datetime, timedelta
import json
from operator import attrgetter
from django.shortcuts import render, redirect
from django.views.generic import TemplateView
from django.contrib.auth import logout
from django.contrib.auth.decorators import login_required
from django.views.decorators.cache import cache_control
from login.models import Musteri
from .models import Location, User
from django.conf import settings
import folium
import redis

redis_instance = redis.StrictRedis(host=settings.REDIS_HOST,
                                  port=settings.REDIS_PORT, db=0)

@login_required(login_url='/')
def home_view(request):
    musteri = Musteri.objects.get(user_id=request.user.id)
    queryset = User.objects.filter(id=request.user.id)
    m = folium.Map(location = [59.408406,16.4460788], zoom_start=5)

    data = getData(musteri)
    
    items1 = []
    items2 = []

    for i in data:
        temp = redis_instance.get(str(i[4])).decode('utf8').replace("'", '"')
        temp = json.loads(temp)
        date_time_str = temp['date']
        date_time_obj = datetime.strptime(date_time_str, '%Y-%m-%d %H:%M')
        location = Location()
        location.arac_id = temp['arac']
        location.lat = temp['lat']
        location.lng = temp['lng']
        location.date = date_time_obj
        if(location.arac_id == str(musteri.arac1)):
            items1.append(location)
        elif(location.arac_id == str(musteri.arac2)):
            items2.append(location)
    items1.sort(key=attrgetter('date'), reverse=True)
    items2.sort(key=attrgetter('date'), reverse=True)

    for i in items1:
        if(((items1[0].date - i.date).total_seconds() / 60) <= 30):
            folium.Marker([i.lat, i.lng], "Araç No: {}\nLatitude:\n{}\nLongitude:\n{}\nTarih: {}".format(i.arac_id,i.lat, i.lng,i.date), icon=folium.Icon(color='red')).add_to(m)
    
    for i in items2:
        if(((items2[0].date - i.date).total_seconds() / 60) <= 30):
            folium.Marker([i.lat, i.lng], "Araç No: {}\nLatitude:\n{}\nLongitude:\n{}\nTarih: {}".format(i.arac_id,i.lat, i.lng,i.date), icon=folium.Icon(color='blue')).add_to(m)
    
    m = m._repr_html_()
    context = {'m': m, "base_country": "TR", "user": queryset[0]}
	
    return render(request, 'home.html', context)

class Home(TemplateView):
    template_name = 'base.html'

@login_required(login_url='/')
def Table(request):
    musteri = Musteri.objects.get(user_id=request.user.id)
    data = getData(musteri)

    baslangic = False
    items = []
    arac = request.GET.get('arac')

    m = folium.Map(zoom_start=8)
    if validParameter(arac) and arac != "Seçiniz...":
        baslangic = True
        for i in data:
            temp = redis_instance.get(str(i[4])).decode('utf8').replace("'", '"')
            temp = json.loads(temp)
            date_time_str = temp['date']
            date_time_obj = datetime.strptime(date_time_str, '%Y-%m-%d %H:%M')
            location = Location()
            location.arac_id = temp['arac']
            location.lat = temp['lat']
            location.lng = temp['lng']
            location.date = date_time_obj
            if(location.arac_id == arac):
                items.append(location)
        items.sort(key=attrgetter('date'), reverse=True)
        m = folium.Map(location = [items[0].lat, items[0].lng], zoom_start=8)

    basTar = request.GET.get('startDate')
    bitTar = request.GET.get('finishDate')
    basSaat = request.GET.get('startTime')
    bitSaat = request.GET.get('finishTime')

    if validParameter(basTar) and validParameter(bitTar) and validParameter(basSaat) and validParameter(bitSaat):
        bitSaat = datetime.strptime(bitSaat, '%H:%M')
        bitTar = datetime.strptime(bitTar, '%Y-%m-%d') + timedelta(hours=bitSaat.hour, minutes=bitSaat.minute)

        basSaat = datetime.strptime(basSaat, '%H:%M')
        basTar = datetime.strptime(basTar, '%Y-%m-%d') + timedelta(hours=basSaat.hour, minutes=basSaat.minute)

        items = [x for x in items if (x.date >= basTar and x.date <= bitTar)]

        for i in items:
            folium.Marker([i.lat, i.lng], "Araç No: {}\nLatitude:\n{}\nLongitude:\n{}\nTarih: {}".format(i.arac_id, i.lat, i.lng, i.date)).add_to(m)

        m = m._repr_html_()

    if(baslangic):
        if len(items) > 0:
            context = {'m': m, 'araclar': [musteri.arac1, musteri.arac2], 'start': items[0].date - timedelta(hours=1), 'finish': items[0].date, 'first': items[len(items)-1].date, 'bool': baslangic, 'selected': int(arac), 'error': False}
        else:
            context = {'araclar': [musteri.arac1, musteri.arac2], 'bool': False, 'selected': int(arac), 'error': True}
    else:
        context = {'araclar': [musteri.arac1, musteri.arac2], 'bool': baslangic, 'error': False}

    return render(request, 'table.html', context)

def validParameter(param):
    return param != '' and param is not None

@cache_control(no_cache=True, must_revalidate=True)
def logOut(request):
    user = request.user
    musteri = Musteri.objects.get(user_id=user.id)
    musteri.cikis = datetime.now()
    musteri.save()
    logout(request)

    return redirect('login')

def getData(musteri : Musteri):
    id = 0
    with open('./data/data.csv') as csv_file:
        dataList = []
        csv_reader = csv.reader(csv_file, delimiter=',')
        for row in csv_reader:
            if(int(row[3]) != musteri.arac1 and int(row[3]) != musteri.arac2):
                continue
            
            data = [row[0], row[1], row[2], row[3], id]
            dataList.append(data)
            redis_instance.set(str(id),str({'date': data[0], 'lat': data[1], 'lng': data[2], 'arac':  data[3]}))
            id += 1
        return dataList
