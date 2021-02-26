#!/bin/bash

function getCurrentRecvBuf() {
    ethtool -g ens160 | grep -A 15 "Current" | grep -i "rx:" | awk '{print $2}'
}

function getCurrentRecvDrops() {
    netstat ens160 -i | grep ens160 | awk '{print $5}'
}

clear

red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
cyan=$(tput setaf 6)
nocolor=$(tput sgr0)

if [[ -z $1 ]]; then
    Interface="ens160"
else
    Interface="$1"
fi

if [[ -z $2 ]]; then
    InitBuffer="96"
else
    InitBuffer="$2"
fi

echo "${cyan}[+] Chosen $Interface to optimize ${nocolor}"
echo "${cyan}[+] Chosen $InitBuffer as initial buffer size ${nocolor}"

bufPreset=$(ethtool -g ens160 | grep "RX:" | head -1 | awk '{print $2}')
bufCurrent=$(ethtool -g ens160 | grep "RX:" | tail -1 | awk '{print $2}')

if [[ $bufCurrent -gt $bufPreset ]]; then
    echo "${red}[-] Current Buffer size $bufCurrent is greater than Preset buffer size $bufPreset ${nocolor}"
    exit 1
fi

echo "${cyan}[+] Preset Buffer size: $bufPreset ${nocolor}"
echo "${cyan}[+] Actual Buffer size: $bufCurrent ${nocolor}"

while ((InitBuffer <= bufPreset)); do
    currentRecBuf=$(getCurrentRecvBuf)
    InitRecvDrop=$(getCurrentRecvDrops)

    echo "${yellow}[*] Current receive buffer size: $currentRecBuf ${nocolor}"
    echo "${yellow}[*] Current receive drops: $InitRecvDrop ${nocolor}"
    echo "${yellow}[+] Changing receive buffer size to $InitBuffer ${nocolor}"
    ethtool -G "$Interface" rx "$InitBuffer"
    NewRecBuf=$(getCurrentRecvBuf)
    echo "${cyan}[+] Changed receive buffer size to $NewRecBuf ${nocolor}"

    for ((i = 0; i < 5; i++)); do
        sleep 1s
        CurrentRecvDrop=$(getCurrentRecvDrops)
        echo " ${yellow}$1 - Current receive drops: $CurrentRecvDrop ${nocolor}"
    done

    if [[ $CurrentRecvDrop > $InitRecvDrop ]]; then
        echo "${red}[-] Buffer size of $NewRecBuf did not work ${nocolor}"
        ((InitBuffer = InitBuffer + 32))
        echo "${red}[-] Next buffer size will be $InitBuffer ${nocolor}"
    else
        echo "${green}[+] Buffer size of $NewRecBuf worked ${nocolor}"
        break
    fi
done
