#!/bin/bash

# Vérifie si le fichier .env existe
if [ ! -f .env ]; then
    echo "Le fichier .env n'existe pas. Création à partir de .env.example..."
    cp .env.example .env
    echo "Fichier .env créé. Vous pouvez le modifier si nécessaire avant de continuer."
    echo "Pour continuer avec les valeurs par défaut, appuyez sur Entrée."
    read
fi

# Arrêt des conteneurs s'ils sont en cours d'exécution
echo "Arrêt des conteneurs existants..."
docker-compose down

# Suppression des volumes pour repartir de zéro (résoudre les problèmes de base de données)
echo "Voulez-vous supprimer les volumes et repartir de zéro ? (o/n)"
read RESET_VOLUMES
if [ "$RESET_VOLUMES" = "o" ] || [ "$RESET_VOLUMES" = "O" ]; then
    echo "Suppression des volumes..."
    docker-compose down -v
fi

# Démarrage des conteneurs
echo "Démarrage des conteneurs..."
docker-compose up -d

# Attente que la base de données soit prête
echo "Attente que les services soient prêts..."
sleep 10

# Vérification de la connexion à la base de données
echo "Vérification de la connexion à la base de données..."
source .env
CONTAINER_NAME=$(docker-compose ps -q db)

# Utilise les variables d'environnement du fichier .env
DB_CHECK=$(docker exec $CONTAINER_NAME mysql -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" -e "SELECT 1" 2>&1)
if [[ $DB_CHECK == *"Access denied"* ]]; then
    echo "⚠️ Problème d'accès à la base de données."
    echo "Réinitialisation des permissions..."
    
    # Réinitialisation des permissions avec l'utilisateur root
    docker exec $CONTAINER_NAME mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "
    DROP USER IF EXISTS '$MYSQL_USER'@'%';
    CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';
    GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';
    FLUSH PRIVILEGES;
    "
    
    echo "Permissions réinitialisées."
else
    echo "✅ Connexion à la base de données réussie."
fi

echo "Démarrage terminé. WordPress est disponible à l'adresse http://localhost:$WP_PORT"
echo "Appuyez sur Ctrl+C pour quitter les logs"

# Affiche les logs
docker-compose logs -f
