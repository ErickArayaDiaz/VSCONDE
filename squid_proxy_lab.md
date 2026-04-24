# Laboratorio: Secure Web Gateway con Squid + ClamAV en AWS

## Descripción general

Simulación de una red corporativa en AWS con dos instancias EC2 — una actúa como proxy Squid con filtrado de contenido, antivirus ClamAV y control de ancho de banda, y la otra como cliente sin acceso directo a internet.

```
Internet
    │
[EC2 Proxy - 10.0.1.111]  ← subred pública (con IGW)
    │  NAT + Squid + ClamAV
[EC2 Cliente - 10.0.2.36] ← subred privada (sin IGW)
```

---

## Índice

1. [Infraestructura AWS](#1-infraestructura-aws)
2. [Instancias EC2](#2-instancias-ec2)
3. [Conexión entre instancias](#3-conexión-entre-instancias)
4. [Configuración NAT en el Proxy](#4-configuración-nat-en-el-proxy)
5. [Instalación y configuración de Squid](#5-instalación-y-configuración-de-squid)
6. [Filtrado de contenido](#6-filtrado-de-contenido)
7. [Bloqueo por horario con switch](#7-bloqueo-por-horario-con-switch)
8. [Límite de ancho de banda (QoS)](#8-límite-de-ancho-de-banda-qos)
9. [Monitor de alertas en tiempo real](#9-monitor-de-alertas-en-tiempo-real)
10. [Antivirus ClamAV + c-icap](#10-antivirus-clamav--c-icap)
11. [Switch maestro](#11-switch-maestro)
12. [Scripts de prueba](#12-scripts-de-prueba)
13. [Arquitectura final](#13-arquitectura-final)

---

## 1. Infraestructura AWS

### 1.1 Crear VPC

```
Consola AWS → VPC → Crear VPC
Nombre: Proxy_Squid
CIDR: 10.0.0.0/16
```

### 1.2 Crear subredes

```
VPC → Subredes → Crear subred

Subred pública (proxy):
  Nombre: proxy
  CIDR: 10.0.1.0/24

Subred privada (cliente):
  Nombre: cliente
  CIDR: 10.0.2.0/24
```

### 1.3 Crear Internet Gateway

```
VPC → Internet Gateways → Crear IGW
Nombre: Proxy_IGW
Adjuntar a VPC: Proxy_Squid
```

### 1.4 Tablas de enrutamiento

**Tabla pública (Squid_publica):**
```
Destino: 0.0.0.0/0 → Target: IGW
Destino: 10.0.0.0/16 → local
Asociar a subred: proxy
```

**Tabla privada (squid_privada):**
```
Destino: 10.0.0.0/16 → local
Asociar a subred: cliente
```
> La ruta `0.0.0.0/0` hacia el proxy se agrega después de crear la instancia proxy.

### 1.5 Security Groups

**SG Proxy:**
```
Inbound:
  SSH (22)         → 0.0.0.0/0
  Custom TCP (3128) → 10.0.2.0/24
  All traffic      → 10.0.2.0/24

Outbound:
  All traffic → 0.0.0.0/0
```

**SG Cliente:**
```
Inbound:
  SSH (22) → 10.0.1.0/24

Outbound:
  All traffic → 0.0.0.0/0
```

---

## 2. Instancias EC2

### 2.1 Key Pair

```
EC2 → Key Pairs → Crear key pair
Nombre: Squid
Tipo: RSA → .pem
```

### 2.2 EC2 Proxy

```
AMI: Ubuntu 24.04 LTS
Tipo: t3.small (2GB RAM — necesario para ClamAV)
Subred: proxy (pública)
IP pública: habilitada
Security Group: proxy
Key Pair: Squid
```

> **Importante:** Deshabilitar Source/Destination Check:
> ```
> EC2 → Instancias → proxy → Acciones → Redes
> → Cambiar verificación de origen/destino → Detener
> ```

### 2.3 EC2 Cliente

```
AMI: Ubuntu 24.04 LTS
Tipo: t3.micro
Subred: cliente (privada)
IP pública: deshabilitada
Security Group: cliente
Key Pair: Squid
```

### 2.4 Agregar ruta en tabla privada

Después de crear la instancia proxy:
```
VPC → Tablas de enrutamiento → squid_privada → Rutas → Editar
Agregar: 0.0.0.0/0 → Instance → seleccionar instancia proxy
```

---

## 3. Conexión entre instancias

### 3.1 Conectarse al proxy

Desde la consola AWS → EC2 Instance Connect, o desde PowerShell:

```powershell
cd C:\Users\<usuario>\Downloads
ssh -i "Squid.pem" ubuntu@<IP_PUBLICA_PROXY>
```

### 3.2 Copiar .pem al proxy

```powershell
scp -i "Squid.pem" "Squid.pem" ubuntu@<IP_PUBLICA_PROXY>:~/.ssh/
```

### 3.3 Conectarse al cliente desde el proxy

```bash
chmod 400 ~/.ssh/Squid.pem
ssh -i ~/.ssh/Squid.pem ubuntu@10.0.2.36
```

### 3.4 Actualizar el cliente

```bash
# Desde el cliente, forzar IPv4 para apt
sudo apt-get -o Acquire::ForceIPv4=true update
sudo apt-get -o Acquire::ForceIPv4=true upgrade -y
```

---

## 4. Configuración NAT en el Proxy

```bash
# Habilitar IP forwarding
sudo sysctl -w net.ipv4.ip_forward=1
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf

# Regla NAT (usar ens5, no eth0)
sudo iptables -t nat -A POSTROUTING -s 10.0.2.0/24 -o ens5 -j MASQUERADE

# Verificar
sudo iptables -t nat -L POSTROUTING -n -v

# Hacer persistente
sudo apt-get install -y iptables-persistent
sudo netfilter-persistent save
```

### Verificar desde el cliente

```bash
ping -c 3 10.0.1.111          # ping al proxy ← debe funcionar
curl --max-time 5 http://example.com  # internet directo ← debe fallar
```

---

## 5. Instalación y configuración de Squid

```bash
sudo apt update && sudo apt install squid -y
```

### Archivo de dominios prioritarios

```bash
sudo tee /etc/squid/dominios_prioritarios.txt << 'EOF'
.ubuntu.com
.debian.org
.microsoft.com
.windowsupdate.com
.kaspersky.com
.kaspersky-labs.com
.avast.com
.avg.com
.symantec.com
.norton.com
.amazonaws.com
.aws.amazon.com
.ec2.internal
EOF
```

---

## 6. Filtrado de contenido

### squid.conf.con_horario

```bash
sudo tee /etc/squid/squid.conf.con_horario << 'EOF'
http_port 3128

acl red_cliente src 10.0.2.0/24

# Dominios bloqueados siempre
acl bloqueados dstdomain .facebook.com .youtube.com .instagram.com

# Palabras clave bloqueadas en URL
acl palabras_bloqueadas url_regex -i /crack /torrent /hack /malware /exploit /porn /pirate

# Extensiones bloqueadas (solo desde dominios no confiables)
acl archivos_bloqueados url_regex -i \.exe$ \.mp4$ \.mp3$ \.avi$ \.mkv$ \.iso$ \.torrent$ \.zip$ \.rar$

# Horario de bloqueo UTC 14:00-18:00 = 10:00-14:00 Chile
acl horario_laboral time MTWHF 14:00-18:00
acl sitios_horario dstdomain .httpbin.org

# Dominios prioritarios desde archivo externo
acl prioritarios dstdomain "/etc/squid/dominios_prioritarios.txt"

# Reglas en orden
http_access deny bloqueados
http_access deny palabras_bloqueadas
http_access deny archivos_bloqueados !prioritarios
http_access deny sitios_horario horario_laboral
http_access allow red_cliente
http_access deny all

# QoS - Pool 1: dominios prioritarios sin límite
delay_pools 2
delay_class 1 2
delay_parameters 1 -1/-1 -1/-1
delay_access 1 allow prioritarios
delay_access 1 deny all

# Pool 2: resto del tráfico limitado
delay_class 2 2
delay_parameters 2 512000/512000 102400/102400
delay_access 2 allow red_cliente
delay_access 2 deny all

# ICAP / ClamAV
icap_enable on
icap_send_client_ip on
icap_send_client_username on
icap_client_username_header X-Authenticated-User
icap_service clamav_service respmod_precache bypass=1 icap://127.0.0.1:1344/squidclamav
adaptation_access clamav_service allow all
EOF
```

### squid.conf.sin_horario

```bash
sudo tee /etc/squid/squid.conf.sin_horario << 'EOF'
http_port 3128

acl red_cliente src 10.0.2.0/24
acl bloqueados dstdomain .facebook.com .youtube.com .instagram.com
acl palabras_bloqueadas url_regex -i /crack /torrent /hack /malware /exploit /porn /pirate
acl archivos_bloqueados url_regex -i \.exe$ \.mp4$ \.mp3$ \.avi$ \.mkv$ \.iso$ \.torrent$ \.zip$ \.rar$
acl prioritarios dstdomain "/etc/squid/dominios_prioritarios.txt"

http_access deny bloqueados
http_access deny palabras_bloqueadas
http_access deny archivos_bloqueados !prioritarios
http_access allow red_cliente
http_access deny all

delay_pools 2
delay_class 1 2
delay_parameters 1 -1/-1 -1/-1
delay_access 1 allow prioritarios
delay_access 1 deny all

delay_class 2 2
delay_parameters 2 512000/512000 102400/102400
delay_access 2 allow red_cliente
delay_access 2 deny all

icap_enable on
icap_send_client_ip on
icap_send_client_username on
icap_client_username_header X-Authenticated-User
icap_service clamav_service respmod_precache bypass=1 icap://127.0.0.1:1344/squidclamav
adaptation_access clamav_service allow all
EOF
```

### squid.conf.libre (sin restricciones)

```bash
sudo tee /etc/squid/squid.conf.libre << 'EOF'
http_port 3128

acl red_cliente src 10.0.2.0/24
http_access allow red_cliente
http_access deny all

delay_pools 1
delay_class 1 2
delay_parameters 1 -1/-1 -1/-1
delay_access 1 allow red_cliente
delay_access 1 deny all
EOF
```

### Aplicar conf y reiniciar

```bash
sudo cp /etc/squid/squid.conf.con_horario /etc/squid/squid.conf
sudo systemctl restart squid
sudo systemctl enable squid
sudo systemctl status squid | grep Active
```

---

## 7. Bloqueo por horario con switch

```bash
sudo tee /usr/local/bin/switch_horario.sh << 'EOF'
#!/bin/bash

ESTADO_FILE="/etc/squid/horario_estado"
BW_FILE="/etc/squid/bw_estado"
CONF_ON="/etc/squid/squid.conf.con_horario"
CONF_OFF="/etc/squid/squid.conf.sin_horario"
CONF_ACTIVO="/etc/squid/squid.conf"

VERDE="\033[0;32m"
ROJO="\033[0;31m"
CYAN="\033[0;36m"
RESET="\033[0m"
NEGRITA="\033[1m"

recargar() { sudo squid -k reconfigure; sleep 1; }

activar_horario() {
    sudo cp "$CONF_ON" "$CONF_ACTIVO"
    echo "on" | sudo tee "$ESTADO_FILE" > /dev/null
    recargar
    echo -e "${NEGRITA}${ROJO}[HORARIO ON]${RESET} Bloqueo 14:00-18:00 UTC activado"
}

desactivar_horario() {
    sudo cp "$CONF_OFF" "$CONF_ACTIVO"
    echo "off" | sudo tee "$ESTADO_FILE" > /dev/null
    recargar
    echo -e "${NEGRITA}${VERDE}[HORARIO OFF]${RESET} Bloqueo horario desactivado"
}

estado() {
    hora_utc=$(date '+%H:%M UTC')
    hora_chile=$(date -d '4 hours ago' '+%H:%M Chile' 2>/dev/null)
    val=$(cat "$ESTADO_FILE" 2>/dev/null || echo "off")
    bw=$(cat "$BW_FILE" 2>/dev/null || echo "on")
    echo -e "\n${NEGRITA}${CYAN}=== ESTADO ACTUAL ===${RESET}"
    echo -e "Hora: ${hora_utc} | ${hora_chile}\n"
    [ "$val" = "on" ] && echo -e "Bloqueo horario : ${NEGRITA}${ROJO}ON${RESET}" || echo -e "Bloqueo horario : ${NEGRITA}${VERDE}OFF${RESET}"
    [ "$bw" = "on" ] && echo -e "Ancho de banda  : ${NEGRITA}${ROJO}LIMITADO${RESET}" || echo -e "Ancho de banda  : ${NEGRITA}${VERDE}SIN LÍMITE${RESET}"
    echo ""
}

case "$1" in
    on)     activar_horario ;;
    off)    desactivar_horario ;;
    status) estado ;;
    *)      echo "Uso: switch_horario.sh [on|off|status]" ;;
esac
EOF

sudo chmod +x /usr/local/bin/switch_horario.sh
```

---

## 8. Límite de ancho de banda (QoS)

El sistema usa `delay_pools` tipo 2 en Squid:

| Pool | Destino | Velocidad |
|------|---------|-----------|
| Pool 1 | Dominios prioritarios | Ilimitado (-1/-1) |
| Pool 2 | Resto del tráfico | 500KB/s agregado / 100KB/s por cliente |

Para probar el límite visualmente (bajar a 10KB/s):
```bash
sudo sed -i 's/delay_parameters 2 [0-9]*\/[0-9]* [0-9]*\/[0-9]*/delay_parameters 2 10000\/10000 10000\/10000/' /etc/squid/squid.conf
sudo squid -k reconfigure
```

Restaurar:
```bash
sudo sed -i 's/delay_parameters 2 [0-9]*\/[0-9]* [0-9]*\/[0-9]*/delay_parameters 2 512000\/512000 102400\/102400/' /etc/squid/squid.conf
sudo squid -k reconfigure
```

---

## 9. Monitor de alertas en tiempo real

```bash
sudo tee /usr/local/bin/squid_alertas.sh << 'EOF'
#!/bin/bash

LOG="/var/log/squid/access.log"
ALERTAS="/var/log/squid/alertas.log"

ROJO="\033[0;31m"
VERDE="\033[0;32m"
AMARILLO="\033[1;33m"
CYAN="\033[0;36m"
RESET="\033[0m"
NEGRITA="\033[1m"

echo -e "${NEGRITA}${CYAN}"
echo "======================================"
echo "   SQUID - MONITOR DE ALERTAS EN VIVO"
echo "======================================"
echo -e "${RESET}"

tail -f "$LOG" | while read linea; do
    timestamp=$(echo "$linea" | awk '{print $1}')
    ip_cliente=$(echo "$linea" | awk '{print $3}')
    resultado=$(echo "$linea" | awk '{print $4}')
    metodo=$(echo "$linea" | awk '{print $6}')
    url=$(echo "$linea" | awk '{print $7}')
    hora=$(date -d "@${timestamp%.*}" '+%H:%M:%S' 2>/dev/null)

    if echo "$resultado" | grep -q "DENIED"; then
        if echo "$url" | grep -qiE '\.(exe|mp4|mp3|avi|mkv|iso|torrent|zip|rar)(\?|$)'; then
            motivo="ARCHIVO BLOQUEADO"
        elif echo "$url" | grep -qiE '/(crack|torrent|hack|malware|exploit|porn|pirate)'; then
            motivo="PALABRA CLAVE"
        else
            motivo="DOMINIO BLOQUEADO"
        fi
        echo -e "${ROJO}${NEGRITA}[BLOQUEADO]${RESET} ${hora} | ${AMARILLO}${ip_cliente}${RESET} | ${motivo} | ${url}"
        echo "[BLOQUEADO] $(date '+%Y-%m-%d') ${hora} | IP: ${ip_cliente} | Motivo: ${motivo} | URL: ${url}" >> "$ALERTAS"
    elif echo "$resultado" | grep -q "TCP_MISS\|TCP_HIT"; then
        echo -e "${VERDE}[PERMITIDO]${RESET} ${hora} | ${ip_cliente} | ${metodo} | ${url}"
    fi
done
EOF

sudo chmod +x /usr/local/bin/squid_alertas.sh
```

Uso:
```bash
sudo squid_alertas.sh
```

---

## 10. Antivirus ClamAV + c-icap

### 10.1 Instalar ClamAV

```bash
sudo apt-get -o Acquire::ForceIPv4=true install -y clamav clamav-daemon
sudo systemctl stop clamav-freshclam
sudo freshclam
sudo systemctl start clamav-daemon
sudo systemctl enable clamav-daemon
sudo systemctl status clamav-daemon | grep Active
```

### 10.2 Instalar c-icap

```bash
sudo apt-get -o Acquire::ForceIPv4=true install -y c-icap libclamav-dev libicapapi-dev
```

### 10.3 Compilar squidclamav

```bash
sudo apt-get -o Acquire::ForceIPv4=true install -y git automake libtool make gcc
cd /tmp
git clone https://github.com/darold/squidclamav.git
cd squidclamav
autoreconf -fi
./configure --with-c-icap
make
sudo make install
```

### 10.4 Configurar squidclamav

```bash
sudo tee /etc/c-icap/squidclamav.conf << 'EOF'
clamd_local /var/run/clamav/clamd.ctl
redirect http://proxy.example.com/cgi-bin/squidclamav?virus=
maxsize 10485760
logredir 1
EOF
```

### 10.5 Configurar c-icap

```bash
sudo tee /etc/c-icap/c-icap.conf << 'EOF'
ServerName ClamAV-Proxy
ServerAdmin webmaster
PidFile /var/run/c-icap/c-icap.pid
CommandsSocket /var/run/c-icap/c-icap.ctl
Timeout 300
MaxKeepAliveRequests 100
KeepAliveTimeout 600
StartServers 3
MaxServers 10
MinSpareThreads 10
MaxSpareThreads 20
ThreadsPerChild 10
MaxRequestsPerChild 0
Port 1344
TmpDir /tmp
MaxMemObject 4096
DebugLevel 0
ModulesDir /usr/lib/x86_64-linux-gnu/c_icap
TemplateDir /usr/share/c_icap/templates
Service squidclamav squidclamav.so
EOF
```

### 10.6 Servicio systemd para c-icap

```bash
sudo tee /lib/systemd/system/c-icap.service << 'EOF'
[Unit]
Description=ICAP server
After=clamav-daemon.service
Requires=clamav-daemon.service

[Service]
Type=forking
ExecStartPre=/bin/mkdir -p /run/c-icap
ExecStartPre=/bin/chown c-icap:c-icap /run/c-icap
ExecStart=/usr/bin/c-icap -f /etc/c-icap/c-icap.conf
PIDFile=/var/run/c-icap/c-icap.pid
User=root
Group=root
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable c-icap
sudo systemctl start c-icap
sudo systemctl status c-icap | grep Active
```

### 10.7 Servidor de prueba EICAR

```bash
# Crear archivo EICAR
echo 'X5O!P%@AP[4\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*' | sudo tee /tmp/eicar.com.txt

# Crear servicio persistente
sudo tee /etc/systemd/system/eicar-server.service << 'EOF'
[Unit]
Description=EICAR test HTTP server
After=network.target

[Service]
WorkingDirectory=/tmp
ExecStart=/usr/bin/python3 -m http.server 8080
Restart=always

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable eicar-server
sudo systemctl start eicar-server
```

### 10.8 Probar detección EICAR

```bash
# Desde el cliente
curl -v -x http://10.0.1.111:3128 "http://10.0.1.111:8080/eicar.com.txt"
```

Respuesta esperada:
```
HTTP/1.1 307 Temporary Redirect
X-Virus-ID: Eicar-Signature FOUND
X-Infection-Found: Type=0; Resolution=2; Threat=Eicar-Signature FOUND
```

---

## 11. Switch maestro

```bash
sudo tee /usr/local/bin/switch_maestro.sh << 'EOF'
#!/bin/bash

CONF_ON="/etc/squid/squid.conf.con_horario"
CONF_OFF="/etc/squid/squid.conf.libre"
CONF_ACTIVO="/etc/squid/squid.conf"
ESTADO_FILE="/etc/squid/maestro_estado"

VERDE="\033[0;32m"
ROJO="\033[0;31m"
AMARILLO="\033[1;33m"
CYAN="\033[0;36m"
RESET="\033[0m"
NEGRITA="\033[1m"

mostrar_banner() {
    echo -e "${NEGRITA}${CYAN}"
    echo "================================================"
    echo "   SECURE WEB GATEWAY - PANEL DE CONTROL"
    echo "================================================"
    echo -e "${RESET}"
}

activar_todo() {
    mostrar_banner
    echo -e "${AMARILLO}Activando todos los sistemas...${RESET}\n"

    echo -e "  [ 1/4 ] Cargando reglas de filtrado..."
    sudo cp "$CONF_ON" "$CONF_ACTIVO"
    sudo find /var/spool/squid -type f -delete 2>/dev/null
    sudo squid -k reconfigure 2>/dev/null
    sleep 1
    echo -e "  ${VERDE}✓${RESET} Squid recargado con restricciones completas"

    echo -e "  [ 2/4 ] Iniciando antivirus ClamAV..."
    sudo systemctl start c-icap 2>/dev/null
    sleep 1
    sudo systemctl is-active c-icap > /dev/null 2>&1 && \
        echo -e "  ${VERDE}✓${RESET} ClamAV + c-icap activo" || \
        echo -e "  ${AMARILLO}⚠${RESET} c-icap no pudo iniciar"

    echo -e "  [ 3/4 ] Preparando monitor de alertas..."
    sleep 1
    echo -e "  ${VERDE}✓${RESET} Monitor listo (ejecuta: sudo squid_alertas.sh)"

    echo -e "  [ 4/4 ] Guardando estado..."
    echo "on" | sudo tee "$ESTADO_FILE" > /dev/null
    sleep 1
    echo -e "  ${VERDE}✓${RESET} Estado guardado\n"

    echo -e "${NEGRITA}${VERDE}================================================"
    echo -e "   SISTEMA COMPLETAMENTE ACTIVO"
    echo -e "================================================${RESET}\n"
    mostrar_estado
}

desactivar_todo() {
    mostrar_banner
    echo -e "${AMARILLO}Desactivando todos los sistemas...${RESET}\n"

    echo -e "  [ 1/4 ] Removiendo restricciones de filtrado..."
    sudo cp "$CONF_OFF" "$CONF_ACTIVO"
    sudo squid -k reconfigure 2>/dev/null
    sleep 1
    echo -e "  ${VERDE}✓${RESET} Squid en modo libre"

    echo -e "  [ 2/4 ] Deteniendo antivirus..."
    sudo systemctl stop c-icap 2>/dev/null
    sleep 1
    echo -e "  ${VERDE}✓${RESET} ClamAV + c-icap detenido"

    echo -e "  [ 3/4 ] Limpiando estado..."
    sleep 1
    echo -e "  ${VERDE}✓${RESET} Listo"

    echo -e "  [ 4/4 ] Guardando estado..."
    echo "off" | sudo tee "$ESTADO_FILE" > /dev/null
    sleep 1
    echo -e "  ${VERDE}✓${RESET} Estado guardado\n"

    echo -e "${NEGRITA}${ROJO}================================================"
    echo -e "   SISTEMA COMPLETAMENTE DESACTIVADO"
    echo -e "================================================${RESET}\n"
    mostrar_estado
}

mostrar_estado() {
    hora_utc=$(date '+%H:%M UTC')
    hora_chile=$(date -d '4 hours ago' '+%H:%M Chile' 2>/dev/null)
    estado=$(cat "$ESTADO_FILE" 2>/dev/null || echo "desconocido")
    squid_ok=$(sudo systemctl is-active squid 2>/dev/null)
    clamav_ok=$(sudo systemctl is-active clamav-daemon 2>/dev/null)
    cicap_ok=$(sudo systemctl is-active c-icap 2>/dev/null)

    grep -q "acl bloqueados" "$CONF_ACTIVO" 2>/dev/null && filtrado="ON" || filtrado="OFF"
    grep -q "horario_laboral" "$CONF_ACTIVO" 2>/dev/null && horario="ON (14:00-18:00 UTC)" || horario="OFF"
    bw=$(grep "delay_parameters 2 " "$CONF_ACTIVO" 2>/dev/null | head -1)
    echo "$bw" | grep -q "\-1/-1" && bw_estado="SIN LÍMITE" || bw_estado="LIMITADO (100KB/s por cliente)"
    [ "$cicap_ok" = "active" ] && av_estado="ACTIVO" || av_estado="INACTIVO"

    echo -e "${NEGRITA}${CYAN}=== ESTADO DEL SISTEMA ===${RESET}"
    echo -e "Hora          : ${hora_utc} | ${hora_chile}\n"
    [ "$estado" = "on" ] && echo -e "Estado general: ${NEGRITA}${ROJO}● PROTECCIÓN ACTIVA${RESET}" || \
    [ "$estado" = "off" ] && echo -e "Estado general: ${NEGRITA}${VERDE}○ SISTEMA LIBRE${RESET}" || \
    echo -e "Estado general: ${AMARILLO}? DESCONOCIDO${RESET}"
    echo ""
    echo -e "  Squid proxy   : $([ "$squid_ok" = "active" ] && echo -e "${VERDE}running${RESET}" || echo -e "${ROJO}stopped${RESET}")"
    echo -e "  ClamAV        : $([ "$clamav_ok" = "active" ] && echo -e "${VERDE}running${RESET}" || echo -e "${ROJO}stopped${RESET}")"
    echo -e "  c-icap        : $([ "$cicap_ok" = "active" ] && echo -e "${VERDE}running${RESET}" || echo -e "${ROJO}stopped${RESET}")"
    echo ""
    echo -e "  Filtrado web  : ${NEGRITA}${filtrado}${RESET}"
    echo -e "  Bloqueo hora  : ${NEGRITA}${horario}${RESET}"
    echo -e "  Ancho de banda: ${NEGRITA}${bw_estado}${RESET}"
    echo -e "  Antivirus     : ${NEGRITA}${av_estado}${RESET}"
    echo ""
}

case "$1" in
    on)     activar_todo ;;
    off)    desactivar_todo ;;
    status) mostrar_banner; mostrar_estado ;;
    *)
        mostrar_banner
        echo "Uso: switch_maestro.sh [on|off|status]"
        echo "  on     → activa TODA la protección"
        echo "  off    → desactiva TODO (modo libre)"
        echo "  status → muestra estado completo"
        ;;
esac
EOF

sudo chmod +x /usr/local/bin/switch_maestro.sh
```

---

## 12. Scripts de prueba

### Script de demo completo (cliente)

```bash
cat << 'EOF' > ~/demo_cliente.sh
#!/bin/bash

PROXY="http://10.0.1.111:3128"
PASS=0
FAIL=0
TOTAL=0

VERDE="\033[0;32m"
ROJO="\033[0;31m"
AMARILLO="\033[1;33m"
CYAN="\033[0;36m"
RESET="\033[0m"
NEGRITA="\033[1m"

check() {
    local descripcion="$1"
    local url="$2"
    local esperado="$3"
    ((TOTAL++))

    respuesta=$(curl -s -o /dev/null -w "%{http_code}" \
        --max-time 8 -x "$PROXY" "$url" 2>/dev/null)

    if [ "$esperado" = "bloqueado" ]; then
        if [ "$respuesta" = "403" ] || [ "$respuesta" = "307" ]; then
            echo -e "  ${VERDE}✓ PASS${RESET} | $descripcion → bloqueado ($respuesta)"
            ((PASS++))
        else
            echo -e "  ${ROJO}✗ FAIL${RESET} | $descripcion → esperaba bloqueo, got $respuesta"
            ((FAIL++))
        fi
    else
        if [ "$respuesta" = "200" ] || [ "$respuesta" = "301" ] || [ "$respuesta" = "302" ]; then
            echo -e "  ${VERDE}✓ PASS${RESET} | $descripcion → accesible ($respuesta)"
            ((PASS++))
        else
            echo -e "  ${ROJO}✗ FAIL${RESET} | $descripcion → esperaba 200, got $respuesta"
            ((FAIL++))
        fi
    fi
}

echo ""
echo -e "${NEGRITA}${CYAN}================================================${RESET}"
echo -e "${NEGRITA}${CYAN}   DEMO COMPLETA - SECURE WEB GATEWAY${RESET}"
echo -e "${NEGRITA}${CYAN}================================================${RESET}"
echo -e "Proxy : ${PROXY}"
echo -e "Hora  : $(date '+%H:%M:%S UTC')"
echo ""

echo -e "${NEGRITA}[ 1 - DOMINIOS BLOQUEADOS ]${RESET}"
check "Facebook"           "http://www.facebook.com"                    "bloqueado"
check "YouTube"            "http://www.youtube.com"                     "bloqueado"
check "Instagram"          "http://www.instagram.com"                   "bloqueado"

echo ""
echo -e "${NEGRITA}[ 2 - PALABRAS CLAVE EN URL ]${RESET}"
check "URL con /crack"     "http://httpbin.org/anything/crack"          "bloqueado"
check "URL con /torrent"   "http://httpbin.org/anything/torrent"        "bloqueado"
check "URL con /malware"   "http://httpbin.org/anything/malware"        "bloqueado"
check "URL con /hack"      "http://httpbin.org/anything/hack"           "bloqueado"
check "URL con /exploit"   "http://httpbin.org/anything/exploit"        "bloqueado"
check "URL con /porn"      "http://httpbin.org/anything/porn"           "bloqueado"
check "URL con /pirate"    "http://httpbin.org/anything/pirate"         "bloqueado"

echo ""
echo -e "${NEGRITA}[ 3 - ARCHIVOS BLOQUEADOS (dominio desconocido) ]${RESET}"
check "Ejecutable .exe"    "http://httpbin.org/anything/setup.exe"      "bloqueado"
check "Video .mp4"         "http://httpbin.org/anything/video.mp4"      "bloqueado"
check "Audio .mp3"         "http://httpbin.org/anything/audio.mp3"      "bloqueado"
check "Imagen .iso"        "http://httpbin.org/anything/ubuntu.iso"     "bloqueado"
check "Torrent .torrent"   "http://httpbin.org/anything/file.torrent"   "bloqueado"
check "Comprimido .zip"    "http://httpbin.org/anything/archive.zip"    "bloqueado"
check "Comprimido .rar"    "http://httpbin.org/anything/archive.rar"    "bloqueado"
check "Video .avi"         "http://httpbin.org/anything/movie.avi"      "bloqueado"
check "Video .mkv"         "http://httpbin.org/anything/movie.mkv"      "bloqueado"

echo ""
echo -e "${NEGRITA}[ 4 - SITIOS PERMITIDOS ]${RESET}"
check "example.com"        "http://example.com"                         "permitido"
check "httpbin.org raiz"   "http://httpbin.org"                         "permitido"
check "httpbin.org /get"   "http://httpbin.org/get"                     "permitido"
check "httpbin.org /ip"    "http://httpbin.org/ip"                      "permitido"

echo ""
echo -e "${NEGRITA}[ 5 - ARCHIVOS PERMITIDOS (dominio confiable) ]${RESET}"
check "ubuntu.com"         "http://archive.ubuntu.com"                  "permitido"

echo ""
echo -e "${NEGRITA}[ 6 - ANTIVIRUS CLAMAV ]${RESET}"
echo -e "  Probando detección EICAR..."
((TOTAL++))
respuesta=$(curl -s -o /dev/null -w "%{http_code}" \
    --max-time 8 --max-redirs 0 -x "$PROXY" \
    "http://10.0.1.111:8080/eicar.com.txt")
if [ "$respuesta" = "307" ] || [ "$respuesta" = "403" ]; then
    echo -e "  ${VERDE}✓ PASS${RESET} | EICAR detectado por ClamAV ($respuesta)"
    ((PASS++))
else
    echo -e "  ${ROJO}✗ FAIL${RESET} | EICAR no bloqueado (got $respuesta)"
    ((FAIL++))
fi

echo ""
echo -e "${NEGRITA}[ 7 - ANCHO DE BANDA ]${RESET}"
echo -e "  Midiendo velocidad (límite: ~100KB/s)..."
((TOTAL++))
velocidad=$(curl -x "$PROXY" -o /dev/null \
    --max-time 20 -w "%{speed_download}" \
    "http://httpbin.org/bytes/2000000" 2>/dev/null)
velocidad_kb=$(echo "$velocidad / 1024" | bc 2>/dev/null)
if [ -n "$velocidad_kb" ] && [ "$velocidad_kb" -gt 0 ] 2>/dev/null; then
    if [ "$velocidad_kb" -lt 200 ]; then
        echo -e "  ${VERDE}✓ PASS${RESET} | Velocidad: ${velocidad_kb} KB/s — límite funcionando"
        ((PASS++))
    else
        echo -e "  ${AMARILLO}~ INFO${RESET} | Velocidad: ${velocidad_kb} KB/s"
    fi
else
    echo -e "  ${AMARILLO}~ INFO${RESET} | No se pudo medir"
fi

echo ""
echo -e "${NEGRITA}${CYAN}================================================${RESET}"
printf "${NEGRITA}  RESULTADO: ${VERDE}%d pasaron${RESET}${NEGRITA}, ${ROJO}%d fallaron${RESET}${NEGRITA} de %d pruebas${RESET}\n" "$PASS" "$FAIL" "$TOTAL"
echo -e "${NEGRITA}${CYAN}================================================${RESET}"
echo ""
EOF

chmod +x ~/demo_cliente.sh
```

---

## 13. Arquitectura final

### Capas de seguridad implementadas

```
Petición del cliente
        │
        ▼
[ CAPA 3 - RED ]
  NAT + iptables
  Tabla de enrutamiento privada
        │
        ▼
[ CAPA 7 - APLICACIÓN - SQUID ]
  ┌─ ¿Dominio bloqueado? ──────────────→ 403
  ├─ ¿Palabra clave en URL? ──────────→ 403
  ├─ ¿Extensión sospechosa + dominio
  │   no confiable? ─────────────────→ 403
  ├─ ¿Dentro de horario bloqueado? ──→ 403
  │
  └─ Pasa los filtros
        │
        ▼
[ CAPA 7 - ANTIVIRUS - ClamAV + c-icap ]
  ┌─ ¿Firma de malware detectada? ───→ 307 (bloqueado)
  └─ Limpio ─────────────────────────→ Cliente recibe el contenido
        │
        ▼
[ QoS - delay_pools ]
  Dominios prioritarios → sin límite
  Resto → 100KB/s por cliente
```

### Resumen de componentes

| Componente | Función | Capa |
|---|---|---|
| iptables + NAT | Enrutamiento del cliente por el proxy | 3 |
| Squid | Proxy HTTP, filtrado de contenido | 7 |
| ACL dstdomain | Bloqueo por dominio | 7 |
| ACL url_regex | Bloqueo por palabra clave y extensión | 7 |
| ACL time | Bloqueo por horario | 7 |
| delay_pools | QoS / límite de ancho de banda | 7 |
| ClamAV + c-icap | Análisis antivirus en tiempo real | 7 |
| squid_alertas.sh | Monitor de eventos en tiempo real | Observabilidad |
| switch_maestro.sh | Panel de control central | Control |

### Comandos principales (proxy)

```bash
switch_maestro.sh on      # activa toda la protección
switch_maestro.sh off     # desactiva todo (modo libre)
switch_maestro.sh status  # muestra estado completo
sudo squid_alertas.sh     # monitor en tiempo real
```

### Comandos principales (cliente)

```bash
~/demo_cliente.sh         # ejecuta suite de pruebas completa
```

---

## Notas importantes

- El proxy debe ser **t3.small** mínimo (2GB RAM) para correr ClamAV correctamente
- Las reglas iptables se guardan con `netfilter-persistent` para sobrevivir reinicios
- La interfaz de red es `ens5`, no `eth0` en instancias EC2 Ubuntu 24.04
- El horario de bloqueo usa UTC — Chile es UTC-4
- Al limpiar caché de Squid (`/var/spool/squid`) ClamAV analiza todos los archivos frescos
- El archivo EICAR es un estándar internacional inofensivo para probar antivirus
