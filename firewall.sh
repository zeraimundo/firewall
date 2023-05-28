#!/bin/bash

local(){

#---------------------------------------Liberando ping da LAN no roteador---------------------------------


iptables -A INPUT -i enp0s8 -s 192.168.6.0/24 -p icmp --icmp-type 8 -j ACCEPT
iptables -A OUTPUT -o enp0s8 -d 192.168.6.0/24 -p icmp --icmp-type 0 -j ACCEPT


#-----------------------------------Liberando o trafego ICMP exceto echo request-------------------------


iptables -A INPUT -i enp0s3 -p icmp ! --icmp-type 8 -j ACCEPT
iptables -A OUTPUT -o enp0s3 -p icmp -j ACCEPT


#----------------------------------Liberando o SSH para o 192.168.6.1------------------------------------


iptables -A INPUT -i enp0s8 -s 192.168.6.1 -d 192.168.6.254 -p tcp --dport 22 -j ACCEPT
iptables -A OUTPUT -o enp0s8 -s 192.168.6.254 -d 192.168.6.1 -p tcp --sport 22 -j ACCEPT



#------------------------Fazendo LOG de tentativas de acesso SSH ao roteador via Internet ---------------


iptables -A INPUT -i enp0s3 -p tcp --dport 22 -j LOG --log-prefix "SSH via Internet      "


#-------------------------------Registrando LOG de requisições DNS da LAN fora do 8.8.8.8------------------


iptables -A FORWARD -s 192.168.6.0/24 -i enp0s8 -o enp0s3 ! -d 8.8.8.8 -p udp --dport 53 -j LOG --log-prefix "DNS inválido!    "


#-------------------------------------------Liberar acesso ao servidor SIAF----------------------------------


iptables -A INPUT -i enp0s8 -s 192.168.6.2 -d 192.168.6.254 -p tcp --dport 5200 -j ACCEPT
iptables -A OUTPUT -o enp0s8 -d 192.168.6.254 -s 192.168.6.2 -p tcp --sport 5200 -j ACCEPT

}

forwarding(){

#--------------------------------Fazendo NAT para a Lan acessar a Internet-------------------------------


iptables -A FORWARD -i enp0s3 -o enp0s8 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -s 192.168.6.0/24 -i enp0s8 -o enp0s3 -d 8.8.8.8 -p udp --dport 53 -j ACCEPT
iptables -A FORWARD -s 192.168.6.0/24 -i enp0s8 -o enp0s3 -p tcp -m multiport --dport 20,21,31,80,443,3306 -j ACCEPT



#-------------------------------Registrando LOG de requisições DNS da LAN fora do 8.8.8.8------------------


iptables -A FORWARD -s 192.168.6.0/24 -i enp0s8 -o enp0s3 ! -d 8.8.8.8 -p udp --dport 53 -j LOG --log-prefix "DNS inválido!    "


#---------------------------------------------Liberar acesso da Internet a DMZ-------------------------------


iptables -t nat -A PREROUTING -i enp0s3 -p tcp --dport 80 -j DNAT --to-destination 172.16.0.9
iptables -A FORWARD -i enp0s3 -o enp0s9 -p tcp --dport 80 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -i enp0s9 -o enp0s3 -p tcp --sport 80 -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -t nat -A PREROUTING -i enp0s3 -p tcp --dport 443 -j DNAT --to-destination 172.16.0.9
iptables -A FORWARD -i enp0s3 -o enp0s9 -p tcp --dport 443 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -i enp0s9 -o enp0s3 -p tcp --sport 443 -m state --state ESTABLISHED,RELATED -j ACCEPT


#---------------------------------------------Liberar acesso a internet da DMZ-------------------------------

iptables -A FORWARD -s 172.16.0.8/29 -i enp0s9 -o enp0s3 -d 8.8.8.8 -p udp --dport 53 -j ACCEPT
iptables -A FORWARD -i enp0s3 -o enp0s9 -d 172.16.0.8/29 -p udp --sport 53 -j ACCEPT
iptables -A FORWARD -s 172.16.0.8/29 -i enp0s9 -o enp0s3 -p tcp -m multiport --dport 80,433 -j ACCEPT
iptables -A FORWARD -i enp0s3 -o enp0s9 -d 172.16.0.8/29 -p tcp -m multiport --sport 80,433 -j ACCEPT

}

internet(){

sysctl -w net.ipv4.ip_forward=1
iptables -t nat -A POSTROUTING -o enp0s3 -d 192.168.6.0/24 -j MASQUERADE
iptables -t nat -A POSTROUTING -o enp0s3 -d 172.16.0.8/29 -j MASQUERADE

}

default(){

iptables -t filter -P INPUT DROP
iptables -t filter -P OUTPUT DROP
iptables -t filter -P FORWARD DROP

}

iniciar(){

local
forwarding
default
internet

}

parar(){

iptables -t filter -P INPUT ACCEPT
iptables -t filter -P OUTPUT ACCEPT
iptables -t filter -P FORWARD ACCEPT
iptables -t nat -F
iptables -t filter -F

}


case $1 in
start|START|Start)iniciar;;
stop|STOP|Stop)parar;;
restart|RESTART|Restart)parar;iniciar;;
listar)iptables -t filter -nvL;;
*)echo "Execute o script com os parâmetros start ou stop ou restart";;
esac

