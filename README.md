# Linux VM Installer

https://www.virtualbox.org/wiki/Download_Old_Builds_7_0
https://download.virtualbox.org/virtualbox/

## Usage

- ...

### TODO

- move postinstall to a file...

### ASL


```bash
export VM_DEBUG=true
export VM_ISO=/tmp/debian.iso

OS_VERSION="12.11.0"

wget -O "$VM_ISO" https://cdimage.debian.org/mirror/cdimage/archive/$OS_VERSION/amd64/iso-dvd/debian-$OS_VERSION-amd64-DVD-1.iso

# create & install VM
./asl_create.sh
```

### Test

```bash
export VM_DEBUG=true
export VM_ISO=/tmp/debian.iso

OS_VERSION="12.11.0"

wget -O "$VM_ISO" https://cdimage.debian.org/mirror/cdimage/archive/$OS_VERSION/amd64/iso-dvd/debian-$OS_VERSION-amd64-DVD-1.iso

# create & install VM
./scripts/vm_create.sh TEST ~/Data/TEST
./scripts/preseed.sh | ./scripts/vm_install.sh TEST -

# SSH
./scripts/install_ssh.sh TEST

# launcher
./scripts/launcher.sh TEST
./scripts/install_desktop.sh TEST

# import/export
./scripts/vm_export.sh TEST ~/Data/TESTC.ova
./scripts/vm_import.sh ~/Data/TESTC.ova TESTC
```

## Scripts

- vm_create : créée la VM
- preseed : crée le fichier de configuration de l'installation.
- vm_install : install Linux sur la VM
- install_ssh
- vm_export
- vm_import
- launcher : démarre la VM dans un terminal
- install_desktop : créée un fichier .desktop

### vm_create

Créée une nouvelle machine virtuelle :
```bash
./scripts/vm_create.sh $VM_NAME $VM_DIR
```

Variables d'environnement:

|Nom|Valeur par défaut|Description|
|--|--|--|
|VM_RAM|4096||
|VM_DISK|8192||
|VM_NB_CPU|4||
|VM_SSH_PORT|8022||

### preseed

Génère la configuraton preseed :
```bash
./scripts/preseed.sh > $PRESEED_FILE
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
|VM_EXTRA_PACKAGES|openssh-server||


Exemple de configuration ici : https://www.debian.org/releases/stable/example-preseed.txt

### vm_install

Installe une nouvelle machine virtuelle :
```bash
./scripts/vm_install.sh $VM_NAME $PRESEED_FILE
# or
./scripts/preseed.sh | ./scripts/vm_install.sh $VM_NAME -
```

Variables d'environnement:

|Nom|Valeur par défaut|Description|
|--|--|--|
|VM_DEBUG|false|si true, permet de visualiser les logs pendant l'installation.|
|VM_ISO||si non fourni, télécharge l'iso.|
|VM_LOGIN|zeus|required for addon installation|
|VM_POSTINSTALL|||

Note : Alt+F4 pour visualiser les logs pendant l'installation (Alt+F1 pour revenir à l'interface graphique).

### ssh_install

```bash
./scripts/ssh_install.sh $VM_NAME
```


### vm_import/export

```bash
./scripts/vm_export.sh $VM_NAME $VM_OVA
./scripts/vm_import.sh $VM_OVA $VM_DIR
```

### launcher

Démarre la machine virtuelle et ouvre une session SSH :
```bash
./scripts/launcher.sh $VM_NAME
```

|Nom|Valeur par défaut|Description|
|--|--|--|
|VM_USER|zeus||
|VM_SSH_PORT|8022||
|VM_IP|127.0.0.1||


### install_desktop

Créée un fichier .desktop :
```bash
./scripts/install_desktop.sh $VM_NAME
```

|Nom|Valeur par défaut|Description|
|--|--|--|
|VM_ICON|./assets/LVMI.svg||