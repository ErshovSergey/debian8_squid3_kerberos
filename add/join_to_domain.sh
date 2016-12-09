#!/bin/bash
export SQUID_DIR=/var/spool/squid3

 . /DEFAULT-SETTINGS/function

write_etc_krb5_conf

add_ns_fileds

if [[  -f $etc_keytab ]]; then
  # если существует $etc_keytab - пробуем авторизоваться с помощью него
  kinit -k -t $etc_keytab HTTP/$proxy_server_name.$domain_name@$DOMAIN_NAME_UPPERCASE

  if [  $? -ne 1 ]; then
    echo "   Already autorisation with '$etc_keytab'."
  else 
    rm $etc_keytab
  fi
  /usr/bin/kdestroy
fi

if [[ ! -f $etc_keytab ]]; then
  # авторизуем в домене
  echo "Login administrator '$login_administrator'. Domain '$domain_name'"
  echo "Enter password for domain '$DOMAIN_NAME_UPPERCASE'"
  kinit $login_administrator@$DOMAIN_NAME_UPPERCASE

  if [ $? -ne 1 ]
  then
    # авторизоваться удалось, добавляем хост в домен
    echo "   Join to domain '$DOMAIN_NAME_UPPERCASE':"
    msktutil -c -b "CN=COMPUTERS" -s HTTP/$proxy_server_name.$domain_name -h $proxy_server_name.$domain_name \
        -k $etc_keytab --computer-name $proxy_server_name --upn HTTP/$proxy_server_name.$domain_name \
        --server $fqdn_domain_controller #--verbose
#    msktutil -c -b "CN=COMPUTERS" -s HTTP/$proxy_server_name.$domain_name -h $proxy_server_name.$domain_name \
#        -k $etc_keytab --computer-name $proxy_server_name --upn HTTP/$proxy_server_name.$domain_name \
#        #--verbose
    [ $? -ne 1 ] && echo "      Success!"

    chown proxy:proxy $etc_keytab && chmod g+r /var/spool/squid3/krb5.keytab
    chmod 644 $etc_keytab

    # проверяем аутентификацию
    echo "   Test authentification:"
    kinit -k -t $etc_keytab HTTP/$proxy_server_name.$domain_name@$DOMAIN_NAME_UPPERCASE
    [ $? -ne 1 ] && echo "      Success with '$etc_keytab'."
  else 
    echo "   ERROR to Join to domain '$DOMAIN_NAME_UPPERCASE'"
  /usr/bin/kdestroy
  fi
fi


