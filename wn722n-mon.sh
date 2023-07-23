#!/bin/bash

clear

echo ""
echo ""
echo ""
echo ""
echo "   ############################## www.hacketheplanet.net.br | hacktheplanet@hacktheplanet.net.br ##############################"
echo "   ##                                                                                                                        ##"
echo "   ##  ██╗  ██╗ █████╗  ██████╗██╗  ██╗    ████████╗██╗  ██╗███████╗    ██████╗ ██╗      █████╗ ███╗   ██╗███████╗████████╗  ##"
echo "   ##  ██║  ██║██╔══██╗██╔════╝██║ ██╔╝    ╚══██╔══╝██║  ██║██╔════╝    ██╔══██╗██║     ██╔══██╗████╗  ██║██╔════╝╚══██╔══╝  ##"
echo "   ##  ███████║███████║██║     █████╔╝        ██║   ███████║█████╗      ██████╔╝██║     ███████║██╔██╗ ██║█████╗     ██║     ##"
echo "   ##  ██╔══██║██╔══██║██║     ██╔═██╗        ██║   ██╔══██║██╔══╝      ██╔═══╝ ██║     ██╔══██║██║╚██╗██║██╔══╝     ██║     ##"
echo "   ##  ██║  ██║██║  ██║╚██████╗██║  ██╗       ██║   ██║  ██║███████╗    ██║     ███████╗██║  ██║██║ ╚████║███████╗   ██║     ##"
echo "   ##  ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝       ╚═╝   ╚═╝  ╚═╝╚══════╝    ╚═╝     ╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚══════╝   ╚═╝     ##"
echo "   ##                                                                                                                        ##"
echo "   ##################################### youtube | instagram | twitter: HackthePlanetBR #######################################"
echo ""
echo ""
echo ""
echo ""
echo "   Script para ativar o modo Monitoramento e injeção de pacote no adaptador TP-Link, modelo TL-WN722n v2 e v3"
echo "   Criano por Hack The Planet" 
echo ""
echo ""
echo "   Sistemas testados: Kali Linux 2023.1 (amd64 e arm64)"
echo ""
echo ""
echo ""
echo ""
echo "  Iniciando  instalação"
echo ""
echo "  É necessário que adaptador TP-Link TL-WN722n V2 ou V3 esteja conectado à porta USB"

#Verifica se o adptador correto está conectado e foi reconhecido pelo sistema
i=1
while [[ $i -le 1 ]]; do
	read -p "  Seu dispositivo está conectado? (S/N) " sn
	if [ $sn = 'S' ] || [ $sn = 's' ] 
	then
		chkwn=$(lsusb | grep -i "WN722N V2/V3")
		if [ -n "$chkwn" ]
		then
			echo ""
			echo "   Dispositivo encontrado, continuando o script"
			(( i += 1 ))
		else
			echo ""
			echo "   Dispositivo não detectado, encerrando o script"}
			(( i += 1 ))
			exit

		fi
	elif [ $sn = 'N' ] || [ $sn = 'n' ]
	then
		echo ""
		echo "   Conecte o adaptador e execute o script novamente"
		(( i += 1 ))
		exit
	else
		echo ""
		echo "   Opção inválida. Digite S(im) ou (N)ão"
	fi
done
 
#Atualizar todo o sistema
sudo apt update
sudo apt upgrade -y
sudo apt dist-upgrade -y

#Instlar bc (Basic Calculator)
sudo apt install bc

#Remover kernel do driver antigo
sudo rmmod r8188eu.ko

#Baixar drivers
git https://github.com/HackThePlanetBR/rtl8188eus
cd rtl8188eus

#Adicionar drivers antigos na blacklist para que não sejam baixados novamente
sudo echo "blacklist r8188eu" > "/etc/modprobe.d/realtek.conf"

#Instalar headeras
sudo apt install gcc make linux-headers-$(uname -r)

#Compilar kernel do driver correto
make
sudo make install
sudo modprobe 8188eu

echo ""
echo ""
echo ""
echo "   Instalação concluída com sucesso!"
echo ""
echo "   Iniciando teste de modo de modo de monitoramento na placa"
echo ""
echo "   ATENÇÃO: nessa etapa, as interfaces de rede sem fio (wlan0...X) serão reiniciadas."
echo "   Se você está executando esse script através de SSH e está conectado ao host utizando"
echo "   uma interface rede wireless, interrompa esse script agora e realize os testes" 
echo "   manualmente, através dos seguintes comandos:"
echo ""
echo "         > ifconfig wlan0 down"
echo "         > airmon-ng check kill"
echo "         > iwconfig wlan0 mode monitor"
echo "         > ifconfig wlan0 up"
echo "         > iwconfig"
echo ""
echo "   Se na interface wlan0 estive sendo exibida a informação Mode:Monitor, parabéns"
echo "   a instalção foi concluída com sucesso. Caso contrário, altere a interfacfe"
echo "   (wlan1, wlan2...) de acordo com as interfaces disponíveis em seu ambiente."
echo "   Para verificar as interfaces disponíveis utilize o comando iwconfig."
echo ""
echo ""

#Verificar se o usuario deseja realizar os testes ou encerrar o script
read -p "  Deseja executar os testes? (S/N) " sn
if [ $sn = 'N' ] || [ $sn = 'n' ]
then
	echo ""
	echo ""
	echo "   Execute os testes manualmente, utilizando as instrucoes acima."
	echo ""
        echo "   Aproveite de maneira ética. Não ataque redes ou dispositivos que não sejam seus, ou que você"
        echo "   não tenha autorização expressa para atacá-los."
        echo ""
        echo "   www.hacketheplanet.net.br | hacktheplanet@hacktheplanet.net.br"
        echo "   youtube | instagram | twitter: HackthePlanetBR"
	echo ""
	echo "   O Scrtipt sera encerrado agora"
	exit
fi

#Verificar qual wlan  utilizar
w=0
while [[ $w -le 20 ]]; do
	chkwlan=$(ifconfig | grep -i "wlan${w}")
	if [ -n "$chkwlan" ]
	then

		#Testar ativação do modo de monitorament
		echo "   Interface wlan${w} encontrada. Testando ativar modo de monitoramento"
		sudo ifconfig wlan$w down
		airmon-ng check kill
		sudo iwconfig wlan$w mode monitor
		sudo ifconfig wlan$w up
		chkmon=$(sudo iwconfig | grep "Mode:Monitor")
		
		#Caso o modo monitor seja ativado, encerrar scritp. Caso contrário testar proxiam interface
		if [ -n "$chkmon" ]
		then
			echo "   Modo de monitoramento ativado na wlan${w}"
			echo "   Instalação concluída com sucesso!"
			echo ""
			echo "   Aproveite de maneira ética. Não ataque redes ou dispositivos que não sejam seus, ou que você"
			echo "   não tenha autorização expressa para atacá-los."
			echo ""
			echo "   Encerrando o script"
			echo ""
			echo "   www.hacketheplanet.net.br | hacktheplanet@hacktheplanet.net.br"
			echo "   youtube | instagram | twitter: HackthePlanetBR"
			w=21
		else
			echo "   Não foi possível alterar a wlan${w} para o modo de monitoramento." 
			echo "   Iniciando teste na próxima interface."
		fi
	else 
        	(( w += 1 ))
	fi
done
