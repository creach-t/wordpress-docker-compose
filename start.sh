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
docker compose down

# Suppression des volumes pour repartir de zéro (résoudre les problèmes de base de données)
echo "Voulez-vous supprimer les volumes et repartir de zéro ? (o/n)"
read RESET_VOLUMES
if [ "$RESET_VOLUMES" = "o" ] || [ "$RESET_VOLUMES" = "O" ]; then
    echo "Suppression des volumes..."
    docker compose down -v
fi

# Démarrage des conteneurs
echo "Démarrage du conteneur MySQL..."
docker compose up -d db  # Démarre d'abord seulement la base de données

# Récupération du nom du conteneur MySQL
source .env
CONTAINER_NAME=$(docker compose ps -q db)

# Vérification que le conteneur est bien démarré
if [ -z "$CONTAINER_NAME" ]; then
    echo "❌ Le conteneur MySQL n'a pas pu démarrer. Vérifiez les logs avec 'docker compose logs db'"
    docker compose logs db
    exit 1
fi

echo "✅ Conteneur MySQL démarré: $CONTAINER_NAME"

# Attente que MySQL soit prêt
echo "Attente que MySQL soit prêt..."
count=0
max_tries=15
while [ $count -lt $max_tries ]; do
    sleep 3
    count=$((count+1))
    echo "- Tentative $count/$max_tries..."
    
    # Vérification simple du statut du conteneur
    CONTAINER_STATUS=$(docker inspect -f '{{.State.Status}}' $CONTAINER_NAME 2>/dev/null)
    if [ "$CONTAINER_STATUS" != "running" ]; then
        echo "❌ Le conteneur MySQL n'est pas en cours d'exécution."
        docker compose logs db
        exit 1
    fi
    
    # Tente une simple connexion pour voir si MySQL est prêt
    if docker exec $CONTAINER_NAME mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "SELECT 1;" &>/dev/null; then
        echo "✅ MySQL est prêt!"
        break
    fi
    
    if [ $count -eq $max_tries ]; then
        echo "❌ MySQL n'a pas répondu après $max_tries tentatives."
        echo "Affichage des logs MySQL:"
        docker compose logs db
        exit 1
    fi
done

# Démarrage de WordPress
echo "Démarrage de WordPress..."
docker compose up -d wordpress

# Attente que WordPress soit prêt
echo "Attente du démarrage de WordPress..."
sleep 5

# Message final
echo ""
echo "✅ Installation terminée!"
echo "WordPress est disponible à l'adresse http://localhost:$WP_PORT"
echo ""
echo "Affichage des logs (appuyez sur Ctrl+C pour quitter) :"

# Affiche les logs
docker compose logs -f
