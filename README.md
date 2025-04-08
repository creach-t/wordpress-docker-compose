# Configuration Docker Compose pour WordPress

Ce dépôt contient une configuration Docker Compose permettant de déployer rapidement un environnement WordPress avec une base de données MariaDB.

## Prérequis

- Docker
- Docker Compose

## Installation

1. Clonez ce dépôt :
```bash
git clone https://github.com/creach-t/wordpress-docker-compose.git
cd wordpress-docker-compose
```

2. Lancez les conteneurs :
```bash
docker-compose up -d
```

3. Accédez à WordPress dans votre navigateur à l'adresse :
```
http://localhost:80
```

## Informations de configuration

### Base de données
- Nom de la base de données : `wordpress`
- Utilisateur : `wpuser`
- Mot de passe : `motdepassefort`
- Mot de passe root : `rootpassword`

### Volumes
- `db_data` : Stockage persistant pour la base de données
- `wp_data` : Stockage persistant pour WordPress

## Arrêt des conteneurs

Pour arrêter les conteneurs sans perdre les données :
```bash
docker-compose down
```

Pour arrêter les conteneurs et supprimer les volumes (perte de données) :
```bash
docker-compose down -v
```

## Personnalisation

Vous pouvez modifier les paramètres dans le fichier `docker-compose.yml` selon vos besoins avant de lancer les conteneurs.