#!/bin/bash

# 1. Gestion des IDs
USER_ID=${PUID:-1000}
GROUP_ID=${PGID:-1000}

# On recrée l'utilisateur steam avec les bons IDs s'il n'existe pas
if ! id -u steam > /dev/null 2>&1; then
    groupadd -g $GROUP_ID steam
    useradd -u $USER_ID -g $GROUP_ID -m steam
fi

# 2. On s'assure que le dossier de destination est prêt et appartient à 'steam'
mkdir -p /home/steam/nightingale-server
chown -R steam:steam /home/steam/nightingale-server /home/steam/steamcmd

# 3. Installation de SteamCMD (si vide)
if [ ! -f "/home/steam/steamcmd/steamcmd.sh" ]; then
    curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" -o /tmp/steamcmd.tar.gz \
    && tar xzvf /tmp/steamcmd.tar.gz -C /home/steam/steamcmd \
    && rm /tmp/steamcmd.tar.gz
    chown -R steam:steam /home/steam/steamcmd
fi

# ON FORCE LES DROITS SUR TOUT LE HOME
chown -R steam:steam /home/steam

# 4. Mise à jour du jeu (On utilise l'AppID 2826720)
echo "--- Téléchargement du jeu ---"
gosu steam /home/steam/steamcmd/steamcmd.sh \
    +@sSteamCmdForcePlatformType linux \
    +force_install_dir "/home/steam/nightingale-server" \
    +login anonymous \
    +app_update 3796810 validate +quit
	
# 5. Configuration
mkdir -p "/home/steam/nightingale-server/NWX/Config"
cat <<EOL > "/home/steam/nightingale-server/NWX/Config/ServerSettings.ini"
[/Script/NWX.NWXServerSettings]
Password=${GAME_PASSWORD}
AdminPassword=${ADMIN_PASSWORD}
RconEnabled=True
RconPort=${RCON_PORT}
RconPassword=${ADMIN_PASSWORD}
EOL
chown -R steam:steam "/home/steam/nightingale-server/NWX/Config"

# 6. Démarrage (Vérification du nom du fichier)
cd "/home/steam/nightingale-server"
# Nightingale utilise souvent NightingaleServer.sh ou NWXServer.sh
if [ -f "./NightingaleServer.sh" ]; then
    exec gosu steam ./NightingaleServer.sh -port="${GAME_PORT}" -EnableCheats -log
else
    exec gosu steam ./NWXServer.sh -port="${GAME_PORT}" -EnableCheats -log
fi
