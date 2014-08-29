# SYNOPSIS
Средство мониторинга

# Запуск, остановка

## посредством монита

/etc/monit/conf.d/glaz.conf :

    ssh moon5.adriver.x
    sudo monit start glaz
    sudo monit stop glaz

## посредством eye

    ssh moon5.adriver.x
    sudo su && su - glaz
    eye start glaz
    eye stop glaz



