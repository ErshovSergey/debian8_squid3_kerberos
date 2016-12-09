[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/github.com/ErshovSergey/master/LICENSE) ![Language](https://img.shields.io/badge/language-bash-yellowgreen.svg)
# debian8_squid3_kerberos в docker
Прокси сервер squid версии 3 на debian 8 с авторизацией в MS ActiveDirectory через Kerberos.

## История
Очень полезная статья [Squid с фильтрацией HTTPS без подмены сертификата, интеграция с Active Directory 2012R2 + WPAD](https://github.com/tarampampam/nod32-update-mirror).
Необходимость держать отдельный хост вызывала неудобство эксплуатации. Есть вероятность при плановом обновлении пакетов остановить предоставление сервиса.
Поиск уже готовых решений не увенчался успехом. Сделал контейнер docker с прокси сервером squid 3 на debian с авторизацией в MS ActiveDirectory и SARG для отчетов, logrotate для ротации логов.

##Описание
Debian в docker'е обновляется до последних версий. Устанавливается всё необходимое для запуска  [squid3](http://www.squid-cache.org/) с авторизацией  с авторизацией в MS ActiveDirectory и [sarg](https://sourceforge.net/projects/sarg/) для отчетов. 
Добавляем хост squid в MS ActiveDirectory для проверки нахождения пользователя в группах AD.
Кеш, логи и настройки хранятся вне контейнера.
#Эксплуатация данного проекта.
##Клонируем проект
```shell
git clone https://github.com/ErshovSergey/debian8_squid3_kerberos.git
```
##Собираем
```shell
cd debian8_squid3_kerberos/
docker build --rm=true --force-rm --tag=ershov/debian8_squid3_kerberos .
```
Создаем папку для хранения настроек, логов и отчетов вне контейнера
```shell
export SHARE_DIR="/opt/docker_data/SQUID3" && mkdir -p $SHARE_DIR
```
Прописываем данные контроллера домена в файле *$SHARE_DIR\\credetinals*.

##Запускаем
Определяем адрес на котором будет запущен прокси сервер и запускаем
```shell
export ip_addr=<ip адрес>
docker run -d --name squid3 --restart=always   -p $ip_add:3128:3128 \
-p $ip_add:3129:80 \
-h squid3.lira.local \
--volume $SHARE_DIR:/var/spool/squid3 \
ershov/debian8_squid3_kerberos
```
##Авторизуем squid в AD
Меняем параметры в файле *$SHARE_DIR\\credetinals* на свои в соответствии с комментариями.
Запускаем, вводим пароль пользователя
```shell
docker exec -i -t squid3 /join_to_domain.sh
```
При повторном запуске должно быть сообщение об уже авторизованном хосте 
```shell
# docker exec -i -t squid3 /join_to_domain.sh
Already autorisation with '/var/spool/squid3/krb5.keytab'.
```
##Прописываем на клиентах
На клиентах прокси сервер должен быть прописан в виде FQDN, т.е. в виде имени компьютера, которое резолвится в ip адрес к которому привязан контейнер squid.
##Логи и ошибки
Логи и ошибки можно посмотреть
```shell
docker logs -f squid3
```
##Удалить контейнер
```shell
docker stop squid3 && docker rm -v squid3
```
##Перезапустить контейнер
```shell
docker restart squid3
```
##Настройка

Все настройки храняться в папке *\$SHARE_DIR\\*
 - настройки прокси сервера - файл *\$SHARE_DIR\\squid.conf*. Для применения настроек необходимо перезапустить контейнер.
 - папка для списков доменов для ACL squid - *\$SHARE_DIR\\FILES_LIST\\*, из squid этот путь виден как */var/spool/squid3/FILES_LIST/*
 - cron файл для запуска sarg - файл *\$SHARE_DIR\\cron_sarg*
 - настройки sarg - файл *\$SHARE_DIR\\sarg.conf*
 - доступ к отчетам sarg - файл *\$SHARE_DIR\\sarg_htpasswd*
 - настройки nginx для sarg - файл *\$SHARE_DIR\\sarg_nginx.conf*
 - папка для отчетов sarg - *\$SHARE_DIR\\report_sarg\\*
 - настройки logrotate для лог файлов - файл *\$SHARE_DIR\\squid_logrotate*
 - папка с ошибками squid - файл *\$SHARE_DIR\\ERRORS\\*

Если файлов настройки не существуют - используются файлы "по-умолчанию".
### <i class="icon-upload"></i>Ссылки
 - [squid](http://www.squid-cache.org/)
 - [sarg](https://sourceforge.net/projects/sarg/)
 - [Запись в блоге](https://)
 - [Редактор readme.md](https://stackedit.io/)

### <i class="icon-refresh"></i>Лицензия MIT

> Copyright (c) 2016 &lt;[ErshovSergey](http://github.com/ErshovSergey/)&gt;

> Данная лицензия разрешает лицам, получившим копию данного программного обеспечения и сопутствующей документации (в дальнейшем именуемыми «Программное Обеспечение»), безвозмездно использовать Программное Обеспечение без ограничений, включая неограниченное право на использование, копирование, изменение, добавление, публикацию, распространение, сублицензирование и/или продажу копий Программного Обеспечения, также как и лицам, которым предоставляется данное Программное Обеспечение, при соблюдении следующих условий:

> Указанное выше уведомление об авторском праве и данные условия должны быть включены во все копии или значимые части данного Программного Обеспечения.

> ДАННОЕ ПРОГРАММНОЕ ОБЕСПЕЧЕНИЕ ПРЕДОСТАВЛЯЕТСЯ «КАК ЕСТЬ», БЕЗ КАКИХ-ЛИБО ГАРАНТИЙ, ЯВНО ВЫРАЖЕННЫХ ИЛИ ПОДРАЗУМЕВАЕМЫХ, ВКЛЮЧАЯ, НО НЕ ОГРАНИЧИВАЯСЬ ГАРАНТИЯМИ ТОВАРНОЙ ПРИГОДНОСТИ, СООТВЕТСТВИЯ ПО ЕГО КОНКРЕТНОМУ НАЗНАЧЕНИЮ И ОТСУТСТВИЯ НАРУШЕНИЙ ПРАВ. НИ В КАКОМ СЛУЧАЕ АВТОРЫ ИЛИ ПРАВООБЛАДАТЕЛИ НЕ НЕСУТ ОТВЕТСТВЕННОСТИ ПО ИСКАМ О ВОЗМЕЩЕНИИ УЩЕРБА, УБЫТКОВ ИЛИ ДРУГИХ ТРЕБОВАНИЙ ПО ДЕЙСТВУЮЩИМ КОНТРАКТАМ, ДЕЛИКТАМ ИЛИ ИНОМУ, ВОЗНИКШИМ ИЗ, ИМЕЮЩИМ ПРИЧИНОЙ ИЛИ СВЯЗАННЫМ С ПРОГРАММНЫМ ОБЕСПЕЧЕНИЕМ ИЛИ ИСПОЛЬЗОВАНИЕМ ПРОГРАММНОГО ОБЕСПЕЧЕНИЯ ИЛИ ИНЫМИ ДЕЙСТВИЯМИ С ПРОГРАММНЫМ ОБЕСПЕЧЕНИЕМ.

