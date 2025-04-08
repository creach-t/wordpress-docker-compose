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
docker-compose up -d db  # Démarre d'abord seulement la base de données

# Attente que la base de données soit prête
echo "Attente que la base de données soit prête..."
source .env
CONTAINER_NAME=$(docker-compose ps -q db)

# Attend que MariaDB soit prêt à accepter des connexions
echo "Attente du démarrage complet de MariaDB..."
count=0
max_tries=30
while [ $count -lt $max_tries ]; do
    sleep 2
    count=$((count+1))
    echo "- Tentative $count/$max_tries..."
    
    # Vérifie si le conteneur est en cours d'exécution
    if ! docker ps | grep -q $CONTAINER_NAME; then
        echo "❌ Le conteneur MariaDB n'est pas en cours d'exécution. Vérifiez les logs avec 'docker-compose logs db'"
        exit 1
    fi
    
    # Vérifie si MariaDB est prêt
    if docker exec $CONTAINER_NAME mysqladmin ping -h localhost -u root --password="$MYSQL_ROOT_PASSWORD" --silent &> /dev/null; then
        echo "✅ MariaDB est prêt!"
        break
    fi
    
    if [ $count -eq $max_tries ]; then
        echo "❌ Impossible de se connecter à MariaDB après $max_tries tentatives."
        echo "Affichage des logs de la base de données pour diagnostic :"
        docker-compose logs db
        exit 1
    fi
done

# Maintenant, démarrer WordPress
echo "Démarrage de WordPress..."
docker-compose up -d wordpress

# Vérification et correction des permissions de la base de données
echo "Vérification des permissions de la base de données..."
DB_CHECK=$(docker exec $CONTAINER_NAME mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "SHOW GRANTS FOR '$MYSQL_USER'@'%';" 2>&1)
if [[ $DB_CHECK == *"ERROR"* ]]; then
    echo "⚠️ L'utilisateur $MYSQL_USER n'existe pas. Création..."
    
    # Création de l'utilisateur et attribution des permissions
    docker exec $CONTAINER_NAME mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "
    CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';
    GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';
    FLUSH PRIVILEGES;
    "
    
    echo "✅ Utilisateur $MYSQL_USER créé avec les permissions nécessaires."
else
    echo "✅ Les permissions sont correctes pour l'utilisateur $MYSQL_USER."
fi

# Redémarrage de WordPress pour s'assurer qu'il utilise les bonnes permissions
echo "Redémarrage de WordPress pour s'assurer qu'il se connecte correctement..."
docker-compose restart wordpress
sleep 5

echo "✅ Installation terminée! WordPress est disponible à l'adresse http://localhost:$WP_PORT"
echo "Affichage des logs (appuyez sur Ctrl+C pour quitter) :"

# Affiche les logs
docker-compose logs -f
