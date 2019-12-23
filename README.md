# finrerty_microservices
Vladislav Kotov microservices repository

# HomeWork №12

1. Клонируем новый репозиторий на локальную машину  
$ git clone git@github.com:Otus-DevOps-2019-08/finrerty_microservices.git

2. Создадим шаблон PR  
$ mkdir .github && cd .github && wget http://bit.ly/otus-pr-template -O PULL_REQUEST_TEMPLATE.md

3. Скопируем файл .travis.yml из предыдущего репозитория для настройки Travis CI

4. Создадим новую директорию для ДЗ  
$ mkdir docker-monolith

5. Установим Docker  
$ sudo apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common  
$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -  
$ sudo apt-get update  
$ sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"  
$ sudo apt-get update  
$ sudo apt-get install docker-ce docker-ce-cli containerd.io

6. Проверяем корректность установки  
$ docker version

7. Возникла ошибка с правами. Необходимо дать пользователю ОС права на работу с Docker без sudo  
$ sudo usermod -aG docker vlad

8. Запустим первый контейнер  
$ docker run hello-world

9. Настроим новый контейнер  
$ docker run -it ubuntu:16.04 /bin/bash

10. Внесём в нём изменения, создадим новый аналогичный контейнер и убедимся, что внесённых изменений в нем нет

11. Выясним имя первого контейнера и запустим его отдельно  
$ docker ps -a --format "table {{.ID}}\t{{.Image}}\t{{.CreatedAt}}\t{{.Names}}"  
$ docker start cfeee4be8a7a  
$ docker attach cfeee4be8a7a

12. Запустим в контейнере процесс bash и создадим новый image уже с этим процессом  
$ docker exec -it cfeee4be8a7a bash  
$ docker commit cfeee4be8a7a vlad/ubuntu-tmp-file

13. Сохраним вывод списка image в файл  
$ docker images > docker-1.log

14. Сделаем вывод docker inspect нашего контейнера и образа  
Выявим разницу. Опишем её в docker-1.log.

15. Удаляем все контейнеры и образы  
$ docker rm $(docker ps -a -q) && docker rmi $(docker images -q)

16. В уже настроенной аутентификации с gcloud изменим проект infra на проект docker

17. Установим Docker Machine  
$ base=https://github.com/docker/machine/releases/download/v0.16.0 && \  
curl -L $base/docker-machine-$(uname -s)-$(uname -m) >/tmp/docker-machine && \  
sudo mv /tmp/docker-machine /usr/local/bin/docker-machine && \  
chmod +x /usr/local/bin/docker-machine

18. Пропишем наш проект в переменную окружения и создадим виртуалку  
$ export GOOGLE_PROJECT=docker-258314  
$ docker-machine create --driver google --google-machine-image \  
https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \  
--google-machine-type n1-standard-1 --google-zone europe-west1-b docker-host  
$ eval $(docker-machine env docker-host)

19. Создадим файлы mongod.conf, start.sh и db_config для создания контейнера с приложением

20. Соберем образ и запустим контейнер  
$ docker build -t reddit:latest .  
$ docker run --name reddit -d --network=host reddit:latest

21. Настроим Firewall  
$ gcloud compute firewall-rules create reddit-app \  
--allow tcp:9292 \  
--target-tags=docker-machine \  
--description="Allow PUMA connections" \  
--direction=INGRESS

22. Залогинимся в Docker Hub и загрузим туда наш образ  
$ docker login  
$ docker tag reddit:latest finrerty/otus-reddit:1.0  
$ docker push finrerty/otus-reddit:1.0

## Дополнительное задание №1

- Описание добавлено в docker-1.log  
Образ - это зафиксированное неизменяемое состояние контейнера на определённый момент времени.  
Соответственно для сохранения любых изменений, произведённых в контейнере и возможности их воспроизведения,  
необходимо сохранить новое состояние контейнера в новый образ.  
  
Новый же контейнер создается в полностью первозданном виде, сохранённом в образе.

## Дополнительное задание №2

Необходимо создать новый инфраструктурный репозиторий.  
- Создадим папку infra, а в ней создадим 3 папки для packer, terraform и ansible:  
$ mkdir infra  
$ mkdir infra/docker && mkdir infra/terraform && mkdir infra/ansible

- Настроим директорию ansible. Воспользуемся общепринятой структурой.

- Теперь в директории environments создадим директорию Stage для описания среды.

- Внутри разместим динамический инвентори inventory.gcp.yml, предварительно выгрузив из gcp ключ доступа к проекту в формате json.
```
plugin: gcp_compute
projects:
  - %my_project%
zones:
  - europe-west1-b
filters: []
auth_kind: serviceaccount
service_account_file: "/home/vlad/.gcp/docker-692c9ab6d314.json"
```

- Настроим всю директорию ansible, добавим групповые переменные и проинициализиуем роль app с помощью команды ansible-galaxy  
$ cd roles && ansible-galaxy init app

- Опишем плейбук для установки Докера в app/tasks/docker.yml  
ОЧЕНЬ ВАЖНО! Необходимо установить модуль pip и питоновский модуль Docker.
```
- name: Install https and cert software
  apt:
    update_cache: yes
    name: "{{ packages }}"
  vars:
    packages:
    - apt-transport-https
    - ca-certificates
    - curl
    - gnupg-agent
    - software-properties-common
    - 
  tags: docker

- name: Add APT Key
  apt_key:
    url: https://download.docker.com/linux/ubuntu/gpg
    state: present
  tags: docker

- name: App Docker repository
  apt_repository:
    repo: deb [arch=amd64] https://download.docker.com/linux/ubuntu xenial stable
    state: present
  tags: docker

- name: Update repos && Docker Installation
  apt:
    update_cache: yes
    name: "{{ packages }}"
  vars:
    packages:
    - docker-ce
    - docker-ce-cli
    - containerd.io
  tags: docker

- name: Install docker python module
  pip:
    name: docker
  tags: docker
```

- Соберем образ убунты с докером с помощью packer  
$ nano packer/app.json
```
{
    "builders": [
        {
            "type": "googlecompute",
            "project_id": "{{user `project_id`}}",
            "image_name": "reddit-base-{{timestamp}}",
            "image_family": "reddit-base",
            "source_image_family": "{{user `source_image_family`}}",
            "zone": "europe-west1-b",
            "ssh_username": "vlad",
            "machine_type": "{{user `machine_type`}}",
            "image_description": "{{user `image_description`}}",
            "disk_size": "{{user `disk_size`}}",
	    "disk_type": "{{user `disk_type`}}",
            "network": "default",
	    "tags": "{{user `type`}}"
        }
    ],
    "provisioners": [
      {
        "type": "ansible",
        "playbook_file": "ansible/playbooks/packer_docker.yml",
        "extra_arguments": ["--tags","docker"],
        "ansible_env_vars": ["ANSIBLE_ROLES_PATH=ansible/roles"]
      }
    ]
}
```

- Создадим variables.json со значениями переменных (в репозиторий загрузил variables.json.example для примера)

- Настроим terraform. В папке terraform создадим директории stage и modules.

- В папке stage создадим main.tf, variables.tf и terraform.tfvars (в репозиторий будет загружен terraform.tfvars.example)

- В папке modules создадим модули app и vpc. Внутри создадим файлы main.tf, variables.tf и outputs.tf

- Добавим переменную server_count в variables.tf и ${count.index} в название сервера, чтобы можно было выбирать количество создаваемых инстансов. По-умолчанию укажем значение 1.

- Инициализиуем созданные модули и среду и создадим инстанс  
$ cd terraform/stage && terraform init  
$ terraform apply --auto-approve

- Теперь напишем плейбук для разворота в созданной машине нашего докер образа
```
- name: Deploy App container
  hosts: all
  environment:
    PYTHONPATH: "/home/path/.local/lib/python2.7/site-packages"
  become: true
  tasks:
    - name: app container
      docker_container:
        name: reddit
        image: finrerty/otus-reddit:1.0
        state: started
        ports: 
          - "9292:9292"
```

- Прогоняем плейбук и сайт становится доступен  
$ ansible-playbook playbooks/deploy.yml


# HomeWork №13

1. Создадим новую ветку  
$ git checkout -b docker-3

2. Подключимся к созданному ранее Docker host  
$ eval $(docker-machine env docker-host)

3. Скачаем архив и распакуем его в репозитории  
$ wget https://github.com/express42/reddit/archive/microservices.zip \  
  && unzip microservices.zip && rm microservices.zip && mv reddit microservices src

4. Создадим докерфайлы для каждого микросервиса

5. Скачаем последний образ MongoDB  
$ docker pull mongo:latest

6. Попробуем собрать образ post:1.0  
$ docker build -t finrerty/post:1.0 ./post-py  
Получаем ошибку. Для её устранения необходимо привести Dockerfile к следующему виду:
```
FROM python:3.6.0-alpine

WORKDIR /app
ADD . /app

RUN apk add --no-cache --virtual .build-deps gcc musl-dev \
    && pip install -r /app/requirements.txt \
    && apk del --virtual .build-deps gcc musl-dev

ENV POST_DATABASE_HOST post_db
ENV POST_DATABASE posts

CMD ["python3", "post_app.py"]
```

7. Теперь соберём все образы  
$ docker build -t finrerty/post:1.0 ./post-py  
$ docker build -t finrerty/comment:1.0 ./comment  
$ docker build -t finrerty/ui:1.0 ./ui  

8. Отметим, что сборка ui началась не с первого шага. Это связано с кэшированием уже выполненных ранее команд

9. Создадим сеть  
$ docker network create reddit

10. Запустим контейнеры  
$ docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db mongo:latest  
$ docker run -d --network=reddit --network-alias=post finrerty/post:1.0  
$ docker run -d --network=reddit --network-alias=comment finrerty/comment:1.0  
$ docker run -d --network=reddit -p 9292:9292 finrerty/ui:1.0  

11. Выполним первое задание со *. Описание выполнения размещено в нижней части раздела по текущему ДЗ.

12. Редактируем файл ui/Dockerfile. Получаем образ меньшего размера  
$ docker build -t finrerty/ui:2.0 ./ui

13. Создадим volume для хранения БД  
$ docker volume create reddit-db

14. Укажем путь к нему для контейнера с БД при создании  
$ docker run -d --network=reddit --network-alias=post_db \  
  --network-alias=comment_db -v reddit_db:/data/db mongo:latest


## Дополнительное задание №1

- Запустим контейнеры с другими сетевыми алиасами и, соответственно, с другими значениями переменных  
$ docker run -d --network=reddit --network-alias=post_db_new --network-alias=comment_db_new mongo:latest  
$ docker run -e POST_DATABASE_HOST=post_db_new \  
-d --network=reddit --network-alias=post_new finrerty/post:1.0  
  
$ docker run -e COMMENT_DATABASE_HOST=comment_db_new \  
  -d --network=reddit --network-alias=comment_new finrerty/comment:1.0  
  
$ docker run -e POST_SERVICE_HOST=post_new -e COMMENT_SERVICE_HOST=comment_new \  
  -d --network=reddit -p 9292:9292 finrerty/ui:1.0

- Проверяем и убеждаемся, что всё работает. Значения переменных можно так же передавать через файл с помощью параметра --env-file

## Дополнительное задание №2

- Уменьшим размеры образов. Начнём с ./ui/Dockerfile:
```
FROM alpine:3.7
RUN apk --update add --no-cache --virtual run-dependencies \
    ruby ruby-dev ruby-json \
    build-base \
    bash \
    && gem install bundler --no-ri --no-rdoc

ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME
ADD Gemfile* $APP_HOME/
RUN bundle install
ADD . $APP_HOME
ENV POST_SERVICE_HOST post
ENV POST_SERVICE_PORT 5000
ENV COMMENT_SERVICE_HOST comment
ENV COMMENT_SERVICE_PORT 9292
CMD ["puma"]
```

- Теперь ./comment/Dockerfile
```
FROM ruby:2.2-alpine
RUN apk --update add --no-cache --virtual run-dependencies \
    bash \
    build-base

ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME
ADD Gemfile* $APP_HOME/
RUN bundle install
COPY . $APP_HOME

ENV COMMENT_DATABASE_HOST comment_db
ENV COMMENT_DATABASE comments

CMD ["puma"]
```

- Размеры образов значительно изменились.  
Было
```
finrerty/ui         2.0                 3d83933037f7        2 hours ago          458MB
finrerty/comment    1.0                 56c64bc005a0        4 hours ago          781MB
```
Стало
```
finrerty/ui         3.0                 adae5db97d32        11 minutes ago       218MB
finrerty/comment    2.0                 af8864dd7226        About a minute ago   305MB
```

# HomeWork №14

1. Создадим новую ветку  
$ git checkout -b docker-4

2. Пересоздадим docker-host  
$ export GOOGLE_PROJECT=docker-258314  
$ docker-machine create --driver google \  
  --google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \  
  --google-machine-type n1-standard-1 \  
  --google-zone europe-west1-b docker-host  
$ eval $(docker-machine env docker-host)

3. Создадим контейнер с предустановленными сетевыми пакетами, выполним ifconfig и удалим его  
$ docker run -ti --rm --network none joffotron/docker-net-tools -c ifconfig  
Теперь выполним:  
$ docker-machine ssh docker-host ifconfig  
Видим несколько сетевых интерфейсов с IP-адресами

4. Попробуем сощдать несколько контейнеров с nginx  
$ docker run --network host -d nginx && docker run --network host -d nginx && docker run --network host -d nginx  

5. Контейнеры (кроме первого) сразу останавливаются. Выявим причину, посмотрев логи одного из контейнеров  
$ docker ps -a
```
CONTAINER ID   IMAGE    COMMAND                  CREATED           STATUS                     PORTS   NAMES
5824d5274061   nginx    "nginx -g 'daemon of…"   4 minutes ago     Exited (1) 4 minutes ago           clever_knuth
c624f6e61f43   nginx    "nginx -g 'daemon of…"   4 minutes ago     Exited (1) 4 minutes ago           jolly_saha
9fd509f714b0   nginx    "nginx -g 'daemon of…"   4 minutes ago     Up 4 minutes                       optimistic_matsumoto
```
$ docker logs 5824d5274061
```
nginx: [emerg] listen() to 0.0.0.0:80, backlog 511 failed (98: Address already in use)
2019/11/16 08:49:32
```

6. Остановим наш работающий контейнер  
$ docker kill 9fd509f714b0

7. Удаляем все остальные контейнеры  
$ docker rm $(docker ps -aq)

8. Настроим на docker-host машине возможность удобного просмотра namespace'ов  
$ docker-machine ssh docker-host sudo ln -s /var/run/docker/netns /var/run/netns

9. Создадим контейнеры с host network и проверим список namespace'ов  
$ docker run --network host -d nginx && docker run --network host -d nginx && docker run --network host -d nginx  
$ docker-machine ssh docker-host sudo ip netns
```
default
```

10. Теперь выполним то же самое, но с none network  
$ docker run --network none -d nginx && docker run --network none -d nginx && docker run --network none -d nginx  
$ docker-machine ssh docker-host sudo ip netns
```
d69c74ad73de
c0c75d2e6d25
23a23905156d
default
```

11. Создадим bridge-сеть и запустим контейнеры без сетевых алиасов. Убедимся, что ничего не работает  
$ docker network create reddit  
$ docker run -d --network=reddit docker mongo:latest  
$ docker run -d --network=reddit finrerty/post:1.0  
$ docker run -d --network=reddit finrerty/comment:2.0  
$ docker run -d --network=reddit finrerty/ui:3.0  

12. Теперь сделаем то же самое с правильными алиасами. Убедимся, что всё работает  
$ docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db mongo:latest  
$ docker run -d --network=reddit --network-alias=post finrerty/post:1.0  
$ docker run -d --network=reddit --network-alias=comment finrerty/comment:2.0  
$ docker run -d --network=reddit -p 9292:9292 finrerty/ui:3.0  

13. Разделим приложение на 2 сети, создадим новые контейнеры и разнесём их по разным сетям  
$ docker network create back_net --subnet=10.0.2.0/24  
$ docker network create front_net --subnet=10.0.1.0/24  
$ docker run -d --network=front_net -p 9292:9292 --name ui finrerty/ui:3.0  
$ docker run -d --network=back_net --name post finrerty/post:1.0  
$ docker run -d --network=back_net --name comment finrerty/comment:2.0  
$ docker run -d --network=back_net --name mongo_db --network-alias=post_db --network-alias=comment_db mongo:latest  
$ docker network connect front_net 0877bc81f885  
$ docker network connect front_net 45d0946df238

14. Установим bridge utils и изучим как устроена наша сеть и какие интерфейсы создают контейнеры  
$ docker-machine ssh docker-host sudo apt-get update $$ docker-machine ssh docker-host sudo apt-get install bridge-utils

15. Установим docker compose, создадим docker-compose.yml и на его основе соберем наше приложение  
$ sudo pip install docker-compose  
$ export USERNAME=finrerty  
$ docker-compose up -d  
$ docker-compose ps

## Самостоятельное задание

- Добавим сети
```
networks:
  front_net:
  back_net:
```

- Добавим сетевые алиасы к контейнеру MongoDB
```
services:
  post_db:
    image: mongo:3.2
    volumes:
      - post_db:/data/db
    networks:
      back_net:
        aliases:
        - post_db
        - comment_db
```

- Создадим файл .env с переменными
```
USERNAME=finrerty
POST_VERSION=1.0
COMMENT_VERSION=2.0
UI_VERSION=3.0
APP_PORT=9292:9292
```

- Отредактируем docker-compose.yml
```
...
ui:
    build: ./ui
    image: ${USERNAME}/ui:${UI_VERSION}
    ports:
      - ${APP_PORT}/tcp
...
post:
    build: ./post-py
    image: ${USERNAME}/post:${POST_VERSION}
...
comment:
    build: ./comment
    image: ${USERNAME}/comment:${COMMENT_VERSION}
```

- Чтобы поменять имя проекта, поменяем имя папки и создадим контейнеры заново  
$ mv src src-test  
$ docker kill $(docker ps -q)  
$ docker-compose up -d  
```
Creating network "src_test_front_net" with the default driver
Creating network "src_test_back_net" with the default driver
Creating volume "src_test_post_db" with default driver
Creating src_test_post_db_1 ... done
Creating src_test_comment_1 ... done
Creating src_test_post_1    ... done
Creating src_test_ui_1      ... done
```

- Вернём всё-таки старое имя :)

## Дополнительное задание №1

Файл docker-compose.override.yml позволяет добавлять дополнительные параметры разворота контейнеров. Указанные в нём инструкции имеют приоритет над инструкциями в docker-compose.yml

- Создадим docker-compose.override.yml
```
version: '3.3'
services:
  post_db:
    volumes:
      - test_db:/data/db
  ui:
    volumes:
      - ui:/home/dev/ui
    command: ["puma","--debug","-w","2"]
  comment:
    volumes:
      - comment:/home/dev/comment
    command: ["puma","--debug","-w","2"]

volumes:
  test_db:
  comment:
  ui:
```

- Теперь при развороте нашего приложения у нас будут создаваться тестовые директории для БД и ui, а ruby будет запускаться в режиме debug с двумя воркерами

- Убеждаемся, что всё работает  
$ docker-compose up -d


# HomeWork №15

1. Создадим новую ветку  
$ git checkout -b gitlab-ci-1

2. Для создания виртуальной машины воспользуемся Docker Machine. Создадим docker-host (HDD 50ГБ)  
$ export GOOGLE_PROJECT=docker-258314  
$ docker-machine create --driver google --google-machine-image \  
https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \  
--google-machine-type n1-standard-1 --google-zone europe-west1-b --google-disk-size 50 docker-host  
$ eval $(docker-machine env docker-host)

3. Создадим необходимые директории  
$ docker-machine ssh docker-host sudo mkdir -p /srv/gitlab/config /srv/gitlab/data /srv/gitlab/logs  

4. Создадим в нашем репозитории docker-compose.yml и исправим в нём IP-адрес  
$ mkdir gitlab-ci && cd gitlab-ci && wget \  
https://gist.github.com/Nklya/c2ca40a128758e2dc2244beb09caebe1

5. Запустим gitlab-ci, убедимся, что всё работает.  
$ docker-compose up -d

6. Создадим пароль для root, отключим возможность регистрации новых пользователей

7. Создадим группу homework и проект example

8. Добавим remote в наш репозиторий  
$ git remote add gitlab http://35.195.250.202/homework/example.git  
$ git push gitlab gitlab-ci-1

9. Создадим файл .gitlab-ci.yml (файл загружен в рабочий репозиторий microservices в папку gitlab-ci)

10. Зарегистрируем runner  
$ docker run -d --name gitlab-runner --restart always \  
  -v /srv/gitlab-runner/config:/etc/gitlab-runner \  
  -v /var/run/docker.sock:/var/run/docker.sock \  
  gitlab/gitlab-runner:latest  
$ docker exec -it gitlab-runner gitlab-runner register --run-untagged --locked=false

11. Находим в настройках (Settings => CI/CD => Runners) наш runner - yYNL11K8 (my-runner)

12. Убеждаемся, что пайплайн запустился. Теперь загрузим код reddit в репозиторий  
$ git clone https://github.com/express42/reddit.git && rm -rf ./reddit/.git  
$ git add reddit/  
$ git commit -m “Add reddit app”  
$ git push gitlab gitlab-ci-1

13. Созаздим simpletest.rb в папке reddit
```
require_relative './app'
require 'test/unit'
require 'rack/test'

set :environment, :test

class MyAppTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_get_request
    get '/'
    assert last_response.ok?
  end
end
```

14. Добавим в reddit/Gemfile строку
```
gem 'rack-test'
```

15. Создадим окружения dev, stage и prod

16. Доработаем динамические окружения и определение рабочих веток


## Дополнительное задание №1

- Создадим build контейнера с приложением. Для создания билда воспользуемся уже имеющимся Dockerfile из ДЗ docker-1
```
build_job:
  image: docker:19.03.1
  stage: build
  services:
    - docker:dind
  before_script:
    - cd reddit
  script:
    - docker build -t finrerty/reddit:$CI_COMMIT_VERSION .
    - docker login -u $DH_LOGIN -p $DH_PASSWORD
    - docker push finrerty/reddit:$CI_COMMIT_VERSION
```


## Дополнительное задание №2

- Реализуем создание gitlab runner с помощью sh-скрипта. Параметры скрипта можно менять.
```
docker run -d --name gitlab-runner --restart always \
  -v /srv/gitlab-runner/config:/etc/gitlab-runner \
  -v /var/run/docker.sock:/var/run/docker.sock \
  gitlab/gitlab-runner:latest
docker exec -it gitlab-runner gitlab-runner register --run-untagged --locked=false
```


## Дополнительное задание №3

- Выполнена настройка уведомлений на канал в Slack:  
https://app.slack.com/client/T6HR0TUP3/CNCMZTBQ8


# HomeWork №16

1. Создадим новую ветку  
$ git checkout -b monitoring-1

2. Создадим правило файрвола для Prometheus  
$ gcloud compute firewall-rules create prometheus-default --allow tcp:9090 

3. Создадим docker-host  
$ export GOOGLE_PROJECT=docker-258314  
$ docker-machine create --driver google \  
  --google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \  
  --google-machine-type n1-standard-1 \  
  --google-zone europe-west1-b docker-host  
$ eval $(docker-machine env docker-host)

4. Создадим контейнер с prometheus  
$ docker run --rm -p 9090:9090 -d --name prometheus prom/prometheus:v2.1.0

5. Изменим структуру нашего репозитория. Перенесём docker-compose.*, .env* файлы и папку docker-monolith в новую директорию docker

6. Создадим папку monitoring/prometheus, в ней создадим Dockerfile и конфигурационный файл  
$ mkdir monitoring && mkdir monitoring/prometheus  
$ nano Dockerfile
```
FROM prom/prometheus:v2.1.0
ADD prometheus.yml /etc/prometheus/
```
$ wget https://gist.github.com/Nklya/bfe2d817f72bc6376fb7d05507e97a1d#file-prometheus-yml

7. Соберём все образы сервисов  
$ for i in ui post-py comment; do cd src/$i; bash docker_build.sh; cd -; done

8. Добавим новый сервис в файл docker/docker-compose.yml
```
services:
...
  prometheus:
    image: ${USERNAME}/prometheus
    ports:
      - ${PROMETHEUS_PORT}/tcp
    volumes:
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--storage.tsdb.retention=1d'

volumes:
  prometheus_data:
```

9. Удалим из этого файла директиву build, а так же поменяем значения переменных для директивы image в файле .env

10. Теперь добавим секцию networks
```
networks:
      - front_net
      - back_net
```

11. Развернём наше приложение и мониторинг  
$ cd docker && docker-compose up -d

12. Проверим работу мониторинга. Остановим сервис, проверим графики и потом запустим его заново  
$ docker-compose stop post  
$ docker-compose start post  

13. Добавим node exporter  
docker-compose.yml
```
node-exporter:
    image: prom/node-exporter:v0.15.2
    user: root
    networks:
      - front_net
      - back_net
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    command:
      - '--path.procfs=/host/proc'
      - '--path.sysfs=/host/sys'
      - '--collector.filesystem.ignored-mount-points="^/(sys|proc|dev|host|etc)($$|/)"'
```
prometheus.yml
```
- job_name: 'node'
  static_configs:
    - targets:
      - 'node-exporter:9100' 
```

14. Запушим образы на DockerHub (https://hub.docker.com/u/finrerty)


## Дополнительное задание №1

- Добавляем mongodb-exporter. Для начала отредактируем docker-compose.yml. Загрузим образ. Укажем сети и порт.
```
mongodb-exporter:
    image: bitnami/mongodb-exporter:latest
    ports:
      - 9216:9216
    networks:
      - back_net
      - front_net
```

- Теперь добавим новый job в prometheus.yml
```
  - job_name: 'mongod'
    static_configs:
      - targets:
        - 'post_db:27017'
```

- Проверим, что БД доступна

## Дополнительное задание №2

- Добавляем мониторинг http наших сервисов с помощью blackbox exporter  
docker-compose.yml
```
  blackbox-exporter:
    image: prom/blackbox-exporter:latest
    networks:
      - back_net
      - front_net
```

- Теперь добавляем job  
prometheus.yml
```
  - job_name: 'blackbox-tcp_check'
    static_configs:
      - targets:
        - 'ui:80'
        - 'comment:80'
        - 'post:80'
```

## Дополнительное задание №3

- Реализован Makefile и размещён в корне репозитория


# HomeWork №17

1. Создадим новую ветку  
$ git checkout -b monitoring-2

2. Создадим docker-host  
$ export GOOGLE_PROJECT=docker-258314  
$ docker-machine create --driver google \  
  --google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \  
  --google-machine-type n1-standard-1 \  
  --google-zone europe-west1-b docker-host  
$ eval $(docker-machine env docker-host)

3. Разделим docker-compose.yml на 2 файла, создав новый docker-compose-monitoring.yml

4. Развернём сервис cadvisor, для этого дополним создание контейнера в docker-compose-monitoring.yml
```
  cadvisor:
    image: google/cadvisor:v0.29.0
    volumes:
      - '/:/rootfs:ro'
      - '/var/run:/var/run:rw'
      - '/sys:/sys:ro'
      - '/var/lib/docker/:/var/lib/docker:ro'
    ports:
      - '8080:8080'
    networks:
      - back_net
```
и создание сервиса в prometheus.yml
```
  - job_name: 'cadvisor'
    static_configs:
      - targets:
        - 'cadvisor:8080'
```

5. Добавляем правило фаерволла для cadvisor  
$ gcloud compute firewall-rules create cadvisor-default --allow tcp:8080

6. Пересобираем контейнер с мониторингом, разворачиваем его и приложение  
$ cd monitoring/prometheus  
$ export USER_NAME=finrerty  
$ docker build -t $USER_NAME/prometheus .  
$ cd ../../docker/  
$ docker-compose up -d  
$ docker-compose -f docker-compose-monitoring.yml up -d

7. Добавляем сервис Grafana  
```
  grafana:
    image: grafana/grafana:5.0.0
    volumes:
      - grafana_data:/var/lib/grafana
    environment:
      - GF_SECURITY_ADMIN_USER=admin
      - GF_SECURITY_ADMIN_PASSWORD=secret
    depends_on:
      - prometheus
    ports:
      - 3000:3000
    networks:
      - back_net
```

8. Запускаем его и создаём правило для фаерволла  
$ docker-compose -f docker-compose-monitoring.yml up -d grafana
$ gcloud compute firewall-rules create grafana-default --allow tcp:3000

9. Импортируем дашборд Docker and system monitoring

10. Создадим 2 новых дэшборда: UI http requests и Rate of UI Requests with Error.

11. Напишем функцию графика, фиксирующую успешные входы  
```
rate(ui_request_count{http_status=~"^[2].*"}[1m])
```

12. Реализуем график-гистограмму и вычислим 95й процентиль времени ответа на запрос

13. Создадим новый дашборд для мониторинга бизнес логики и создадим 2 графика
```
rate(post_count[1h])
```
```
rate(comment_count[1h])
```

14. Настроим алертинг в канал Slack - https://app.slack.com/client/T6HR0TUP3/CNCMZTBQ8

15. Соберем образ alertmanager из Dockerfile  
$ docker build -t $USER_NAME/alertmanager .

16. Добавим новый сервис в docker-compose-monitoring.yml
```
  alertmanager:
    image: ${USER_NAME}/alertmanager
    command:
      - '--config.file=/etc/alertmanager/config.yml'
    ports:
      - 9093:9093
    networks:
      - back_net
```

17. Создадим alerts.yml
```
groups:
  - name: alert.rules
    rules:
    - alert: InstanceDown
      expr: up == 0
      for: 1m
      labels:
        severity: page
      annotations:
        description: '{{ $labels.instance }} of job {{ $labels.job }} has been down for more than 1 minute'
        summary: 'Instance {{ $labels.instance }} down'
```

18. Дополним Dockerfile prometheus и файл prometheus.yml
```
FROM prom/prometheus:v2.1.0
ADD prometheus.yml /etc/prometheus/
ADD alerts.yml /etc/prometheus/
```

```
rule_files:
  - "alerts.yml"

alerting:
  alertmanagers:
  - scheme: http
    static_configs:
    - targets:
      - "alertmanager:9093"
```

19. Проверим работу алертинга, сбщ пришло в чат - https://app.slack.com/client/T6HR0TUP3/CNCMZTBQ8

20. Пушим всё на DockerHub (https://hub.docker.com/u/finrerty)   
$ make push_all


## Дополнительные задания

- Добавлена сборка и пуш алертменеджера в Makefile


# HomeWork №18

1. Создадим новую ветку  
$ git checkout -b logging-1

2. Создадим docker-host  
$ export GOOGLE_PROJECT=docker-258314  
$ docker-machine create --driver google \  
  --google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \  
  --google-machine-type n1-standard-1 \  
  --google-zone europe-west1-b \  
  --google-open-port 5601/tcp \  
  --google-open-port 9411/tcp \  
  logging  
$ eval $(docker-machine env logging)  
$ export USER_NAME=finrerty

3. Соберем образы с микросервисами приложения  
$ make build_all

4. Создадим docker-compose-logging.yml. Чтобы всё заработало, к разделу elasticsearch добавим:
```
    environment:
      - node.name=elasticsearch
      - cluster.name=docker-cluster
      - node.master=true
      - cluster.initial_master_nodes=elasticsearch
      - bootstrap.memory_lock=true
      - "ES_JAVA_OPTS=-Xms1g -Xmx1g"
    ulimits:
      nofile:
        soft: 65535
        hard: 65535
      memlock:
        soft: -1
        hard: -1
    expose:
      - 9200
      - 9300
    volumes:
      - efk-data:/usr/share/elasticsearch/data
    ports:
      - "9200:9200"
      - "9300:9300"
```

5. Так же необходимо создать общую сеть
```
networks:
  log_net:
```

6. Создадим директорию logging/fluentd с докерфайлом и fluent.conf и настроим хост logging:  
$ docker-host ssh logging sudo sysctl -w vm.max_map_count=262144

7. Соберем docker image для fluentd  
$ docker build -t $USER_NAME/fluentd .

8. Подправим .env-файл (изменения отражены в .env.example)

9. Определим драйвер для логирования для сервиса post внутри compose-файла
```
…
  post:
…
    logging:
      driver: "fluentd"
      options:
        fluentd-address: localhost:24224
  tag: service.post
```

10. Подправим Dockerfile сервиса comment
```
RUN tzdata \
```

11. Поднимем инфраструктуры  
$ cd docker && docker-compose -f docker-compose-logging.yml up -d  
$ docker-compose up -d

12. Проверим, что всё корректно работает. Изучим возможности Kibana.

13. Добавим фильтр для парсинга json логов, приходящих от post сервиса, в конфиг fluentd
```
<source>
  @type forward
  port 24224
  bind 0.0.0.0
</source>

<filter service.post>
  @type parser
  format json
  key_name log
</filter>
<match *.**>
  @type copy

```

14. Убедимся, что логи структурированы

15. Добавим к сервису ui логгирование
```
  ui:
    image: ${USERNAME}/ui:${UI_VERSION}
    environment: 
      - POST_SERVICE_HOST=post
      - POST_SERVICE_PORT=5000
      - COMMENT_SERVICE_HOST=comment
      - COMMENT_SERVICE_PORT=9292
    ports:
      - ${APP_PORT}/tcp
    logging: 
      driver: "fluentd"
      options:
        fluentd-address: localhost:24224
        tag: service.ui
    networks:
      - front_net
```

16. Перезапустим сервис  
$ docker-compose stop ui  
$ docker-compose rm ui  
$ docker-compose up -d

17. Добавим grok-шаблоны для парсинга логов
```
<filter service.ui>
  @type parser
  format grok
  grok_pattern %{RUBY_LOGGER}
  key_name log
</filter>

<filter service.ui>
  @type parser
  format grok
  grok_pattern service=%{WORD:service} \| event=%{WORD:event} \| request_id=%{GREEDYDATA:request_id} \| message='%{GREEDYDATA:message}'
  key_name message
  reserve_data true
</filter>
```

18. Выполним задание со *, распарсив message. Выполнение описано в пункте "Дополнительное задание №1"

19. Добавим zipkin в compose-файлы  
docker-compose-logging.yml
```
services:
  zipkin:
    image: openzipkin/zipkin
    ports:
      - "9411:9411"
```
docker-compose.yml
```
- ZIPKIN_ENABLED=${ZIPKIN_ENABLED}
```
.env
```
ZIPKIN_ENABLED=true
```

20. Пересоздадим всё  
$ docker-compose down  
$ docker-compose -f docker-compose-logging.yml down  
$ docker-compose up -d  
$ docker-compose -f docker-compose-logging.yml up -d

## Дополнительное задание №1

- Добавим ещё один grok-фильтр
```
<filter service.ui>
  @type parser
  format grok
  grok_pattern service=%{WORD:service} \| event=%{WORD:event} \| path=%{GREEDYDATA:path} \| request_id=%{GREEDYDATA:request_id} \| remote_addr=%{IP:remote_addr} \| method=%{SPACE}%{GREEDYDATA:method} response_status=%{GREEDYDATA:response_status}
  key_name message
  reserve_data true
</filter>
```


# HomeWork №19

- Пройден ручной разворот кластера Kubernetes по инструкции:  
https://github.com/kelseyhightower/kubernetes-the-hard-way/

- Единственным отличием от указанной инструкции является использование одного worker вместо трёх. 3 не создались из-за условий триалки.

- Все созданные в процессе файлы сохранены в директории kubernetes/the_hard_way

- В директории kubernetes/reddit созданы базовые (нерабочие) шаблоны файлов разворота приложения


# HomeWork №20

1. Создадим новую ветку  
$ git checkout -b kubernetes-2

2. Kubectl и VirtualBox уже были установлены ранее. Ставим Minikube  
$ curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube_1.6.2.deb  && sudo dpkg -i minikube_1.6.2.deb

3. Создадим и запустим ui-deployment.yml и comment-deployment.yml  
$ kubectl apply -f ui-deployment.yml  
$ kubectl apply -f comment-deployment.yml

4. Создадим post-deployment.yml
```
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: post
  labels:
    app: reddit
    component: post
spec:
  replicas: 3
  selector:
    matchLabels:
      app: reddit
      component: post
  template:
    metadata:
      name: post
      labels:
        app: reddit
        component: post
    spec:
      containers:
      - image: finrerty/post
        name: post
```

5. Создадим mongo-deployment.yml и запустим  
$ kubectl apply -f mongo-deployment.yml

6. Теперь необходимо создать сервисы. Для начала - comment-service.yml
```
---
apiVersion: v1
kind: Service
metadata:
  name: comment
  labels:
    app: reddit
    component: post
spec:
  ports:
  - port: 9292
    protocol: TCP
    targetPort: 9292
  selector:
    app: reddit
    component: comment
```

7. Затем - post-service.yml
```
---
apiVersion: v1
kind: Service
metadata:
  name: post
  labels:
    app: reddit
    component: post
spec:
  ports:
  - port: 5000
    protocol: TCP
    targetPort: 5000
  selector:
    app: reddit
    component: post
```

8. Так же создадим mongodb-service.yml и задеплоим все новые сущности  
$ kubectl apply -f .

9. Убедимся, что база не работает. Необходимо создать сервисы, сохраненные в переменных Dockerfile  
comment-mongodb-service.yml
```
---
apiVersion: v1
kind: Service
metadata:
  name: comment-db
  labels:
    app: reddit
    component: mongo
    comment-db: "true"
spec:
  ports:
  - port: 27017
    protocol: TCP
    targetPort: 27017
  selector:
    app: reddit
    component: mongo
    comment-db: "true"
```
post-mongodb-service.yml
```
---
apiVersion: v1
kind: Service
metadata:
  name: post-db
  labels:
    app: reddit
    component: mongo
    post-db: "true"
spec:
  ports:
  - port: 27017
    protocol: TCP
    targetPort: 27017
  selector:
    app: reddit
    component: mongo
    post-db: "true"
```

10. Так же обновим mongo-deployment.yml, добавив информацию о comment-db и post-db в labels
```
labels:
  comment-db: "true"
  post-db: "true"
```

11. И добавим переменные окружения аналогичные указанным в Dockerfile'ах в Deployment POD'ов
```
        env:
        - name: POST_DATABASE_HOST
          value: post-db
```
```
        env:
        - name: COMMENT_DATABASE_HOST
          value: comment-db
```

12. Обновляем и создаём все объекты, а так же удаляем лишнее  
$ kubectl apply -f . && kubectl delete -f mongodb-service.yml

13. Теперь необходимо разрешить доступ к нашему приложению извне, допишем NodePort
```
spec:
  type: NodePort
  ports:  
  - nodePort: 32092
    port: 9292
    protocol: TCP
    targetPort: 9292
```

14. Проверим, что всё работает. Просмотрим dashboard.

15. Создадим новый Namespace - dev. Опишем его в файле dev-namespace.yml
```
---
apiVersion: v1
kind: Namespace
metadata:
  name: dev
```

16. Запустим приложение в dev Namespace  
$ kubectl apply -n dev -f .

17. Допишем указание значения Namespace'a на главную страницу сервиса в ui-deployment.yml
```
    spec:
      containers:
      - image: finrerty/ui
        name: ui
        env:
        - name: ENV
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
```

18. Создадим кластер kubernetes в GCP и получим к нему доступ из командной строки  
$ gcloud container clusters get-credentials cluster-1 --zone europe-west1-b --project docker-258314

19. Создадим Namespace и наше приложение в этом Namespace  
$ kubectl apply -f dev-namespace.yml && kubectl apply -f . -n dev

20. Добавляем правило Firewall и убеждаемся, что наше приложение работает  
$ gcloud compute firewall-rules create reddit-k8s-default --allow tcp:32092
