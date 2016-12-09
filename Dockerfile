FROM debian:jessie

ENV BuildData 20161209
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -qqy && apt-get upgrade -qqy \
## Set LOCALE to UTF8
  && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
  && echo "ru_RU.UTF-8 UTF-8" >> /etc/locale.gen  \
  && apt-get install -yqq  --no-install-recommends --no-install-suggests \
                     locales \
  && echo "LANG=\"ru_RU.UTF-8\"" > /etc/default/locale \
  && echo "LC_ALL=\"ru_RU.UTF-8\"" >> /etc/default/locale \
  && export LANG=ru_RU.UTF-8 \
  # удаляем все локали кроме этих
  && locale-gen --purge ru_RU.UTF-8 en_US.UTF-8 \
# timezone
  && echo "Europe/Moscow" > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata
RUN cd /tmp/ \
  && apt-get install -yq squid3 krb5-user msktutil sarg nginx

RUN cd /tmp/ \
  && apt-get install -yq nano telnet procps \
  && echo "\nexport TERM=xterm" >> ~/.bashrc

EXPOSE 3128/tcp 3129/tcp

#VOLUME ["${SQUID_DIR}"]

#RUN cd /tmp/ \
## kerberos
#  && chown proxy:proxy /etc/squid3/HTTP.keytab \
#  && chmod g+r /etc/squid3/HTTP.keytab \
#  && echo "KRB5_KTNAME=/var/spool/squid3/krb5.keytab" > /etc/default/squid3 \
#  && echo "export KRB5_KTNAME"                        >> /etc/default/squid3 \
#  && echo "KRB5RCACHETYPE=none"                       >> /etc/default/squid3 \
#  && echo "export KRB5RCACHETYPE"                     >> /etc/default/squid3 \
## sarg
#  && ln -sf /var/spool/squid3/sarg.conf /etc/sarg/sarg.conf

#COPY [  "sarg.conf.orig", "sarg_htpasswd.orig", "cron_sarg", \#
#	"function", "join_to_domain.sh", "credetinals", \
#	"squid_logrotate", "squid_user.conf", \
#	"entrypoint.sh", \
#	"nginx.conf", "sarg_nginx.conf", \
#	"supervisord.conf", \
#	"squid.conf", \
#"/docker_files/" ]


#RUN chmod 755 /docker_files/entrypoint.sh /docker_files/join_to_domain.sh

ENTRYPOINT ["/entrypoint.sh"]
COPY [ "add/", "/" ]

#RUN cd /tmp/ \
#  apt-get clean && \
#  rm -rf /var/cache/apt/* && \
#  rm -rf /var/lib/apt/* && \
#  rm -rf /var/lib/dpkg/* && \
#  rm -rf /var/lib/cache/* && \
#  rm -rf /var/lib/log/* && \
#  rm -rf /usr/share/i18n/ && \
#  rm -rf /usr/share/doc/ && \
#  rm -rf /usr/share/locale/ && \
#  rm -rf /usr/share/man/ && \
#  rm -rf /usr/sbin/locale-gen && \
#  rm -rf /usr/sbin/update-locale && \
#  rm -rf /usr/sbin/validlocale
