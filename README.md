# Linux VM Installer

## Usage

- ...

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
./VirtualBox/preseed.sh
```

Variables d'environnement:

|Nom|Valeur par défaut|Description|
|--|--|--|
|USER|Zeus||
|LOGIN|zeus||
|PWD|1234||
|HOSTNAME|LVMI||
|DOMAIN|$HOSTNAME.localhost||
|LOCALE|fr_FR||
|KEYBOARD|fr||
|COUNTRY|FR||
|TZ|Europe/Paris||
|MIRROR|mirror.dsi.uca.fr||
|MIRROR_DIR|/debian/debian/||
|PROXY|$http_proxy||


#### install

Installe une nouvelle machine virtuelle :
```bash
./VirtualBox/install.sh $VM_NAME
```

Variables d'environnement:

|Nom|Valeur par défaut|Description|
|--|--|--|
|USER|Zeus|(useful ?)|

TODO: post install commands...