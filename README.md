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

2. Créez un fichier `.env` à partir du modèle :
```bash
cp .env.example .env
```

3. Modifiez le fichier `.env` selon vos besoins :
```bash
nano .env
# ou
vim .env
# ou utilisez l'éditeur de votre choix
```

4. Lancez les conteneurs :
```bash
docker-compose up -d
```

5. Accédez à WordPress dans votre navigateur à l'adresse :
```
http://localhost:7899
```
(le port est configuré dans votre fichier .env)

## Variables d'environnement

Toutes les variables de configuration sont stockées dans le fichier `.env`. Voici les principales :

### Base de données
- `MYSQL_DATABASE` : Nom de la base de données (par défaut : wordpress)
- `MYSQL_USER` : Utilisateur de la base de données (par défaut : wpuser)
- `MYSQL_PASSWORD` : Mot de passe de l'utilisateur (par défaut : motdepassefort)
- `MYSQL_ROOT_PASSWORD` : Mot de passe root (par défaut : rootpassword)

### WordPress
- `WORDPRESS_DB_HOST` : Hôte de la base de données (par défaut : db:3306)
- `WORDPRESS_DB_NAME` : Nom de la base de données (par défaut : wordpress)
- `WORDPRESS_DB_USER` : Utilisateur WordPress (par défaut : wpuser)
- `WORDPRESS_DB_PASSWORD` : Mot de passe de l'utilisateur (par défaut : motdepassefort)

### Réseau
- `WP_PORT` : Port sur lequel WordPress sera accessible (par défaut : 7899)

### Volumes
Les volumes suivants sont configurés pour la persistance des données :
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

## Sécurité

Pour une utilisation en production :
1. Assurez-vous de modifier tous les mots de passe par défaut dans le fichier `.env`
2. Ne versionnez jamais votre fichier `.env` contenant vos informations sensibles (il est déjà dans le .gitignore)
3. Envisagez d'ajouter un reverse proxy avec HTTPS comme Traefik ou Nginx
