# Configuration Docker Compose pour WordPress

Ce dépôt contient une configuration Docker Compose permettant de déployer rapidement un environnement WordPress avec une base de données MariaDB.

## Prérequis

- Docker
- Docker Compose

## Installation et démarrage (Méthode recommandée)

1. Clonez ce dépôt :
```bash
git clone https://github.com/creach-t/wordpress-docker-compose.git
cd wordpress-docker-compose
```

2. Rendez le script de démarrage exécutable :
```bash
chmod +x start.sh
```

3. Lancez le script de démarrage :
```bash
./start.sh
```

Le script va :
- Créer un fichier `.env` à partir de `.env.example` s'il n'existe pas déjà
- Vous proposer de réinitialiser les volumes si nécessaire (utile en cas de problème)
- Démarrer les conteneurs
- Vérifier la connexion à la base de données et corriger les permissions si nécessaire
- Afficher les logs des conteneurs

## Installation manuelle (Alternative)

Si vous préférez configurer manuellement :

1. Créez un fichier `.env` à partir du modèle :
```bash
cp .env.example .env
```

2. Modifiez le fichier `.env` selon vos besoins :
```bash
nano .env
```

3. Lancez les conteneurs :
```bash
docker-compose up -d
```

4. Accédez à WordPress dans votre navigateur à l'adresse :
```
http://localhost:7899
```
(le port est configuré dans votre fichier .env)

## Résolution des problèmes courants

### Erreur "Error establishing a database connection"

Si vous rencontrez cette erreur :

1. Utilisez le script `start.sh` qui corrige automatiquement les problèmes de permission
2. Ou exécutez manuellement :
```bash
docker-compose down -v  # Supprime les volumes pour repartir de zéro
docker-compose up -d    # Redémarre les conteneurs
```

### Message "Access denied for user..."

Ce problème peut survenir si les informations d'identification ne sont pas correctes :

1. Vérifiez que les mots de passe dans le fichier `.env` sont simples (sans caractères spéciaux)
2. Assurez-vous que `MYSQL_USER` et `MYSQL_PASSWORD` correspondent aux valeurs utilisées par WordPress
3. Utilisez le script `start.sh` qui réinitialise les permissions de la base de données

## Variables d'environnement

Toutes les variables de configuration sont stockées dans le fichier `.env`. Voici les principales :

### Base de données
- `MYSQL_DATABASE` : Nom de la base de données (par défaut : wordpress)
- `MYSQL_USER` : Utilisateur de la base de données (par défaut : wpuser)
- `MYSQL_PASSWORD` : Mot de passe de l'utilisateur (par défaut : password123)
- `MYSQL_ROOT_PASSWORD` : Mot de passe root (par défaut : rootpass123)

### WordPress
- `WORDPRESS_DB_HOST` : Hôte de la base de données (par défaut : db:3306)
- `WORDPRESS_DB_NAME` : Nom de la base de données (par défaut : wordpress)

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
