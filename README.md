# SYNOPSIS
Средство мониторинга

# Запуск, остановка

## посредством монита

/etc/monit/conf.d/glaz.conf :

    ssh localhost
    sudo monit start glaz
    sudo monit stop glaz

## посредством eye

    ssh localhost
    sudo su && su - glaz
    eye start glaz
    eye stop glaz



