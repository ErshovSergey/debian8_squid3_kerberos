#!/bin/bash
set -e

export LANG=ru_RU.UTF-8
export SQUID_DIR=/var/spool/squid3
export DEBIAN_FRONTEND=noninteractive
export SQUID_CACHE_DIR=${SQUID_DIR}/cache
export SQUID_LOG_DIR=${SQUID_DIR}/logs
export SQUID_USER=proxy

# настройки kerberos по умолчанию
[ ! -f $SQUID_DIR/credetinals ] && cp /DEFAULT-SETTINGS/credetinals $SQUID_DIR/

. /DEFAULT-SETTINGS/function

# пишем krb5.conf
write_etc_krb5_conf

# добавляем dns записи
add_ns_fileds

# папка для кеша
mkdir -p ${SQUID_CACHE_DIR}
touch $SQUID_DIR/access.log
chown -R ${SQUID_USER}:${SQUID_USER} ${SQUID_CACHE_DIR}
if [[ ! -d ${SQUID_CACHE_DIR}/00 ]]; then
  echo "Initializing cache..."
  $(which squid3) -N -z
fi

#### SARG ####
[ ! -d $SQUID_DIR/report_sarg ]   && mkdir $SQUID_DIR/report_sarg
# conf файл для sarg
[ ! -f $SQUID_DIR/sarg.conf ]     && cp /DEFAULT-SETTINGS/sarg.conf 		$SQUID_DIR/
[ ! -f $SQUID_DIR/sarg_htpasswd ] && cp /DEFAULT-SETTINGS/sarg_htpasswd 	$SQUID_DIR/
rm /etc/sarg/sarg.conf 		  && ln -sf $SQUID_DIR/sarg.conf 		/etc/sarg/sarg.conf

#### CRON ####
# если нет файла для cron - копируем дефолтный 
[ ! -f $SQUID_DIR/cron_sarg ]     && cp DEFAULT-SETTINGS/cron_sarg  	$SQUID_DIR/
[ ! -f /etc/cron.d/cron_sarg ]    && ln -sf $SQUID_DIR/cron_sarg /etc/cron.d/

#### NGINX ####
rm /etc/nginx/nginx.conf && cp /DEFAULT-SETTINGS/nginx.conf /etc/nginx/
# conf файл для nginx в части доступа к sarg
[ ! -f $SQUID_DIR/sarg_nginx.conf ] && cp /DEFAULT-SETTINGS/sarg_nginx.conf 	$SQUID_DIR/

#### SQUID ####
# ошибки для пользователя
[ ! -d $SQUID_DIR/ERRORS ] && mkdir $SQUID_DIR/ERRORS && cp /usr/share/squid3/errors/ru/* $SQUID_DIR/ERRORS/
# конф.файл
[ ! -f $SQUID_DIR/squid.conf  ] && cp /DEFAULT-SETTINGS/squid.conf $SQUID_DIR/squid.conf
rm /etc/squid3/squid.conf
[ -f $SQUID_DIR/squid.conf ] && ln -sf $SQUID_DIR/squid.conf /etc/squid3/squid.conf
# папка со списками для ACL squid'а
[ ! -d $SQUID_DIR/FILES_LIST ] && mkdir -p $SQUID_DIR/FILES_LIST

# logrotate squid logs
[ ! -f $SQUID_DIR/squid_logrotate ] && cp /DEFAULT-SETTINGS/squid_logrotate $SQUID_DIR/
[ -f /etc/logrotate.d/squid3 ] && rm /etc/logrotate.d/squid3
[ ! -f /etc/logrotate.d/squid_logrotate ] && ln -sf $SQUID_DIR/squid_logrotate /etc/logrotate.d/squid_logrotate

# папка для лог файлов
[ ! -d $SQUID_DIR/logs ] && mkdir -p $SQUID_DIR/logs \
                         && touch $SQUID_DIR/logs/access.log $SQUID_DIR/logs/cache.log \
                         && chmod -R 755 $SQUID_DIR/logs \
                         && chown -R ${SQUID_USER}:${SQUID_USER} $SQUID_DIR/logs

service squid3 start
service nginx start
service cron start
export LANG=ru_RU.UTF-8 && /usr/bin/sarg -xd day-0

tail -F $SQUID_DIR/logs/cache.log /var/log/nginx/error.log
