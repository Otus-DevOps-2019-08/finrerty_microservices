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
