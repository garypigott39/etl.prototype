# Python "django" etl project

See training video https://www.youtube.com/watch?v=u1GnZfDw5LU

## Setup venv

Copy the setup (& tidyPip) scripts from the ce_pb_app repo, edit as required, and then run:

```shell
./scripts/setup.sh
```

## Install django

```shell
pip install django
pip freeze > requirements.txt
```

## Create django project

```shell
mkdir app
django-admin startproject _config app
```

## Create django app

```shell
cd demo
django-admin startapp ce_core
```

## Start the app

```shell
python manage.py runserver
```

## Migrate db tables

```shell
python manage.py makemigrations
```

You can then check the generated migration files and even turn off the auto-generation of migrations if you want to write them by hand.

Once you're happy with the migration files, run: 

```shell
python manage.py migrate
``` 

## Create superuser 

```shell 
python manage.py createsuperuser
```

## Access admin page 

Just go to site url **/admin** and login

## manage.py shell

```shell 
python manage.py shell 
```

## run application with gunicorn

```shell 
gunicorn config.wsgi:application 
```

## Using Postgres

Change the database settings in `config/settings.py` to use Postgres instead of the default SQLite. 
You will need to have Postgres installed and a database created for your project. 

```shell
pip install psycopg2-binary
```

Example settings:

```python 
DATABASES = { 
    'default': {
        'ENGINE': 'django.db.backends.postgresql', 
        'NAME': 'your_db_name', 
        'USER': 'your_db_user', 
        'PASSWORD': 'your_db_password', 
        'HOST': 'localhost', 
        'PORT': '5432', 
    } 
} 
``` 

After updating the settings, run the migrations again to create the necessary table + create superuser etc.

If you want you can import an existing schema but see ChatGPT for help with that...

