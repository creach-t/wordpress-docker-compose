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
- Démarrer d'abord la base de données puis attendre qu'elle soit prête
- Démarrer WordPress une fois la base de données initialisée
- Vérifier et corriger les permissions de la base de données si nécessaire
- Afficher les logs des conteneurs

**Important** : Quand le script vous demande si vous voulez supprimer les volumes, répondez "o" pour nettoyer complètement l'installation si vous rencontrez des problèmes.

## Installation manuelle (Alternative)

Si vous préférez configurer manuellement, vous pouvez suivre ces étapes, mais la méthode avec le script est plus fiable :

1. Créez un fichier `.env` à partir du modèle :
```bash
cp .env.example .env
```

2. Modifiez le fichier `.env` selon vos besoins :
```bash
nano .env
```

3. Lancez les conteneurs en séquence :
```bash
docker compose up -d db      # Démarrer d'abord la base de données
sleep 20                     # Attendre que la base de données soit prête
docker compose up -d         # Démarrer WordPress
```

4. Accédez à WordPress dans votre navigateur à l'adresse :
```
http://localhost:7899
```
(le port est configuré dans votre fichier .env)

## Résolution des problèmes courants

### Si le conteneur MariaDB ne démarre pas ou est "unhealthy"

Ce problème est résolu dans la dernière version. Si vous l'observez encore :

1. Mettez à jour votre dépôt vers la dernière version :
```bash
git pull
```

2. Supprimez complètement tous les conteneurs et volumes :
```bash
docker compose down -v
```

3. Utilisez le script de démarrage amélioré :
```bash
chmod +x start.sh
./start.sh
```

### Erreur "Error establishing a database connection"

Si vous rencontrez cette erreur après l'installation :

1. Vérifiez les logs pour identifier le problème :
```bash
docker compose logs
```

2. Si vous voyez des erreurs "Access denied for user...", utilisez notre script de démarrage :
```bash
./start.sh
```
Répondez "o" à la question sur la suppression des volumes pour repartir de zéro.

3. Si le problème persiste, vérifiez que le conteneur de base de données est bien en cours d'exécution :
```bash
docker compose ps
```

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
docker compose down
```

Pour arrêter les conteneurs et supprimer les volumes (perte de données) :
```bash
docker compose down -v
```

## Sécurité

Pour une utilisation en production :
1. Assurez-vous de modifier tous les mots de passe par défaut dans le fichier `.env`
2. Ne versionnez jamais votre fichier `.env` contenant vos informations sensibles (il est déjà dans le .gitignore)
3. Envisagez d'ajouter un reverse proxy avec HTTPS comme Traefik ou Nginx
