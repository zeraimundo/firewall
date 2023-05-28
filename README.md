# IPTABLES [<img src="https://img.icons8.com/color/48/000000/console.png" alt="Shell Script" width="20"/>](https://en.wikipedia.org/wiki/Shell_scripting)  [<img src="https://img.icons8.com/color/48/000000/firewall.png" alt="iptables" width="20"/>](https://en.wikipedia.org/wiki/Iptables)

# Inicialização automática do IPTABLES no Linux (Debian Like)

Este projeto tem como objetivo automatizar a inicialização do iptables no ambiente Linux (Debian Like) para fornecer uma camada adicional de segurança ao servidor. Ao seguir os passos abaixo, você será capaz de configurar o iptables para iniciar automaticamente com as regras especificadas.

## Passos para inicialização automática do iptables:

1. Crie um arquivo de regras do iptables em formato de script shell (`.sh`). Recomendamos utilizar o arquivo de exemplo `firewall.sh` fornecido neste repositório. Esse arquivo contém as regras personalizadas do firewall, além de um script que permite iniciar com a variável `start`, parar com `stop` e visualizar as regras com `listar`. Salve o arquivo no diretório `/usr/local/sbin` e conceda permissão de execução utilizando o comando `chmod +x firewall.sh`.

2. Em seguida, crie o arquivo de inicialização do firewall no diretório `/lib/systemd/system` com o nome `firewall.service`. O conteúdo do arquivo deve ser o seguinte:

```ruby
[Unit]
Description=Firewall.sh é um script contendo regras personalizadas de firewall
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/local/sbin/firewall.sh start
ExecStop=/usr/local/sbin/firewall.sh stop
KillMode=process
RemainAfterExit=true

[Install]
WantedBy=multi-user.target
```

Esse arquivo definirá o serviço `firewall.service` e permitirá o uso dos comandos nativos do Linux, como `systemctl start firewall.service`, `systemctl stop firewall.service` e `systemctl restart firewall.service`, em conjunto com o script `firewall.sh`.

Por fim, habilite o serviço utilizando o comando `systemctl enable firewall.service`. Dessa forma, sempre que o sistema iniciar, as regras de firewall configuradas no arquivo `firewall.sh` serão aplicadas automaticamente.
Certifique-se de revisar e personalizar as regras do firewall no arquivo `firewall.sh` de acordo com suas necessidades de segurança.
