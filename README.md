# Linux VM Installer

## Usage

- ...

### Test

```bash
export VM_DEBUG=true
export VM_ISO=/tmp/debian.iso
export VM_ADDON=/tmp/addon.iso

wget -O "$VM_ISO" https://cdimage.debian.org/debian-cd/current/amd64/iso-dvd/debian-12.11.0-amd64-DVD-1.iso
wget -O "$VM_ADDON" https://download.virtualbox.org/virtualbox/7.0.0_BETA3/VBoxGuestAdditions_7.0.0_BETA3.iso

./VirtualBox/create.sh TEST ~/Data/TEST
./VirtualBox/preseed.sh | ./VirtualBox/install.sh TEST -
```

## Scripts

### VirtualBox

#### create

Créée une nouvelle machine virtuelle :
```bash
./VirtualBox/create.sh $VM_NAME $VM_DIR
```

Variables d'environnement:

|Nom|Valeur par défaut|Description|
|--|--|--|
|VM_RAM|4096||
|VM_DISK|8192||
|VM_NB_CPU|4||

#### preseed

Génère la configuraton preseed :
```bash
./VirtualBox/preseed.sh > $PRESEED_FILE
```

Variables d'environnement:

|Nom|Valeur par défaut|Description|
|--|--|--|
|VM_USER|Zeus||
|VM_LOGIN|zeus||
|VM_PWD|1234||
|VM_HOSTNAME|LVMI||
|VM_DOMAIN|$VM_HOSTNAME.localhost||
|VM_LOCALE|fr_FR||
|VM_KEYBOARD|fr||
|VM_TZ|Europe/Paris||
|VM_MIRROR|mirror.dsi.uca.fr||
|VM_MIRROR_DIR|/debian/debian/||
|VM_PROXY|$http_proxy||

Exemple de configuration ici : https://www.debian.org/releases/stable/example-preseed.txt

TODO: VM_EXTRA_PACKAGES.

#### install

Installe une nouvelle machine virtuelle :
```bash
./VirtualBox/install.sh $VM_NAME $PRESEED_FILE
# or
./VirtualBox/preseed.sh | ./VirtualBox/install.sh $VM_NAME -
```

Variables d'environnement:

|Nom|Valeur par défaut|Description|
|--|--|--|
|VM_DEBUG|false|si true, permet de visualiser les logs pendant l'installation.|
|VM_ISO||si non fourni, télécharge l'iso.|
|VM_ADDON||si non fourni, télécharge l'iso.|
|VM_LOGIN|zeus|required for addon installation|

Note : Alt+F4 pour visualiser les logs pendant l'installation (Alt+F1 pour revenir à l'interface graphique).

TODO: post install commands...
TODO: GRUB - remove 5 sec waiting
TODO: VM create : opti waiting port SATA
TODO: remove swap