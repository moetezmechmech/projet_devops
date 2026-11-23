#!/usr/bin/env bash
# ==============================================================================
# Script de retour arrière (Rollback) - Exigence Point 7 du professeur
# Permet de revenir instantanément à une version antérieure sans reconstruire l'image.
# Exemple d'usage : ./scripts/rollback.sh v1.0.0
# ==============================================================================

set -eo pipefail

TARGET_VERSION="${1}"

if [ -z "$TARGET_VERSION" ]; then
    echo "⚠️ Usage: $0 <version-precedente> (Exemple: $0 v1.0.0)"
    echo "Recherche de la version précédente par défaut (v1.0.0)..."
    TARGET_VERSION="v1.0.0"
fi

echo "=========================================================="
echo "🔄 DÉCLENCHEMENT DU RETOUR ARRIÈRE (ROLLBACK)"
echo "📌 Version cible vers laquelle revenir : $TARGET_VERSION"
echo "=========================================================="

export APP_VERSION="$TARGET_VERSION"

echo "📥 1. Récupération des images publiées de la version $TARGET_VERSION (Aucune reconstruction locale)..."
docker compose pull backend frontend

echo "🚀 2. Bascule et redémarrage des conteneurs vers la version $TARGET_VERSION..."
docker compose up -d --no-build backend frontend

echo "🔍 3. Exécution du contrôle de santé post-rollback..."
if [ -f "./check_health.sh" ]; then
    ./check_health.sh
elif [ -f "../check_health.sh" ]; then
    ../check_health.sh
fi

echo "=========================================================="
echo "✅ RETOUR ARRIÈRE EFFECTUÉ AVEC SUCCÈS VERS $TARGET_VERSION !"
echo "=========================================================="
