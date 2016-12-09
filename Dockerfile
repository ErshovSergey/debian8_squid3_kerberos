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
  && echo "Europe/Moscow" > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata \
  && apt-get install -yq squid3 krb5-user msktutil sarg nginx

EXPOSE 3128/tcp 3129/tcp

ENTRYPOINT ["/entrypoint.sh"]
COPY [ "add/", "/" ]
