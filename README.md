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
