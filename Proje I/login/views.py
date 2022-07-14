from asyncio.windows_events import NULL
from datetime import datetime
from django.shortcuts import redirect, render

from login.models import Musteri
from .forms import LoginForm
from django.contrib.auth import authenticate, login
from django.contrib import messages

def login_view(request):
    form = LoginForm(request.POST or None)
    if request.method == 'POST':
        username = request.POST.get('username')
        password = request.POST.get('password')
        user = authenticate(request, username=username, password=password)

        if user is not None:
            login(request, user)
            musteri = Musteri.objects.get(user_id=user.id)
            if musteri is not None:
                musteri.giris = datetime.now()
                musteri.save()
            else:
                musteri = Musteri(user=user, giris= datetime.now(), cikis=NULL)
                musteri.save() 

            return redirect('home')
        else:
            messages.warning(request, 'Kullanıcı Bilgileri Hatalı!')
    
    context = {'form': form}
    return render(request, 'login.html', context)