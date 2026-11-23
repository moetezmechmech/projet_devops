#!/usr/bin/env bash
# ==============================================================================
# Script de contrôle automatisé (Atelier 2 - Exigences du Professeur)
# Renvoie 0 en cas de succès, un code non nul (1) en cas d'échec.
# ==============================================================================

set -o pipefail

BACKEND_URL="${1:-http://localhost:5000/health}"
FRONTEND_URL="${2:-http://localhost:80}"
MAX_RETRIES=20
WAIT_SECONDS=3

echo "=========================================================="
echo " [CONTRÔLE DE SANTÉ] Démarrage des vérifications..."
echo "=========================================================="

# 1. Vérification du Backend
echo -n "⏳ Vérification du Backend ($BACKEND_URL)... "
retry=0
until curl -s -f "$BACKEND_URL" > /dev/null; do
    retry=$((retry + 1))
    if [ $retry -ge $MAX_RETRIES ]; then
        echo ""
        echo "❌ ERREUR : Le service Backend ne répond pas après $((MAX_RETRIES * WAIT_SECONDS)) secondes !"
        echo "Dernier code HTTP reçu : $(curl -s -o /dev/null -w "%{http_code}" "$BACKEND_URL" 2>/dev/null || echo "Injoignable")"
        exit 1
    fi
    sleep $WAIT_SECONDS
done
echo "✅ OK (Code 200 reçu)"

# 2. Vérification du Frontend
echo -n "⏳ Vérification du Frontend ($FRONTEND_URL)... "
retry=0
until curl -s -f "$FRONTEND_URL" > /dev/null; do
    retry=$((retry + 1))
    if [ $retry -ge $MAX_RETRIES ]; then
        echo ""
        echo "❌ ERREUR : Le service Frontend ne répond pas après $((MAX_RETRIES * WAIT_SECONDS)) secondes !"
        echo "Dernier code HTTP reçu : $(curl -s -o /dev/null -w "%{http_code}" "$FRONTEND_URL" 2>/dev/null || echo "Injoignable")"
        exit 1
    fi
    sleep $WAIT_SECONDS
done
echo "✅ OK (Code 200 reçu)"

echo "=========================================================="
echo "🎉 TOUS LES CONTRÔLES SONT VALIDES : Succès (Code 0)"
echo "=========================================================="
exit 0
