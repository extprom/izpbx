# docker run --name izpbx-test izpbx-asterisk:20.10.0-16 /bin/bash -c "$(cat check-install.sh)"
#!/bin/bash
# check-install.sh

echo "=== Vérification de l'installation ==="

# 1. Vérification d'Asterisk
echo -n "Vérification d'Asterisk: "
if asterisk -V | grep "${ASTERISK_VER}" > /dev/null; then
    echo "OK ($(asterisk -V))"
else
    echo "ERREUR - Version incorrecte ou non installée"
fi

# 2. Vérification de FreePBX
echo -n "Vérification de FreePBX: "
if [ -f "/var/www/html/admin/index.php" ] && fwconsole -V | grep "^${FREEPBX_VER}" > /dev/null; then
    echo "OK ($(fwconsole -V))"
else
    echo "ERREUR - Non installé ou version incorrecte"
fi

# 3. Vérification du module configedit
echo -n "Vérification du module configedit: "
if [ -d "/var/www/html/admin/modules/configedit" ] && fwconsole ma list | grep "^configedit" > /dev/null; then
    echo "OK"
else
    echo "ERREUR - Module non installé"
fi

# 4. Vérification des composants additionnels
echo "Vérification des composants additionnels:"

# Vérification d'izsynth
echo -n "- izsynth: "
if [ -x "/usr/local/bin/izsynth" ]; then
    echo "OK"
else
    echo "ERREUR - Non installé"
fi

# Vérification de Zabbix
echo -n "- Zabbix Agent: "
if zabbix_agent2 -V > /dev/null 2>&1; then
    echo "OK ($(zabbix_agent2 -V))"
else
    echo "ERREUR - Non installé"
fi

# Vérification de ionCube
echo -n "- ionCube Loader: "
if php -m | grep "ionCube" > /dev/null; then
    echo "OK"
else
    echo "ERREUR - Non installé"
fi

# 5. Vérification des configurations
echo "Vérification des configurations:"

# Asterisk
echo -n "- Configuration Asterisk: "
if [ -f "/etc/asterisk/asterisk.conf" ]; then
    echo "OK"
else
    echo "ERREUR - Fichiers de configuration manquants"
fi

# FreePBX
echo -n "- Configuration FreePBX: "
if [ -f "/etc/freepbx.conf" ]; then
    echo "OK"
else
    echo "ERREUR - Configuration FreePBX manquante"
fi

# 6. Test de connexion à Asterisk
echo -n "Test de connexion à Asterisk CLI: "
if asterisk -rx "core show version" > /dev/null 2>&1; then
    echo "OK"
else
    echo "ERREUR - Impossible de se connecter à Asterisk"
fi

# 7. Vérification des ports
echo "Vérification des ports requis:"
for port in 80 443 5060 5160 8088 8089; do
    echo -n "- Port $port: "
    if netstat -tuln | grep ":$port " > /dev/null; then
        echo "OK"
    else
        echo "NON OUVERT"
    fi
done

echo "=== Fin des vérifications ==="