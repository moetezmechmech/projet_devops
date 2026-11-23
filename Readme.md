# Paris Trees Data Visualization — DevOps Project

Projet DevOps (Licence 3 DSI - ISET) réalisé par **Moetez Mechmech**.  
Chaîne CI/CD complète, conteneurisation Docker, orchestration Docker Compose, tests automatisés, contrôle de santé et retour arrière (Rollback).

Dépôt officiel : [https://github.com/moetezmechmech/projet_devops.git](https://github.com/moetezmechmech/projet_devops.git)

### Liens des Pipelines CI/CD (Rendu professeur) :
* 🟢 **Exécution réussie (Pipeline Vert - PR #1) :** [https://github.com/moetezmechmech/projet_devops/actions/runs/45284380195](https://github.com/moetezmechmech/projet_devops/actions/runs/45284380195)
* 🔴 **Exécution en échec (Pipeline Rouge - PR #2) :** [https://github.com/moetezmechmech/projet_devops/actions/runs/45285864838](https://github.com/moetezmechmech/projet_devops/actions/runs/45285864838)

---

## 🚀 Démarrage en une seule commande

Pour cloner et démarrer l'ensemble du projet en local :

```bash
docker compose up -d
```

L'application est ensuite directement accessible :
* **Frontend Web** : [http://localhost](http://localhost) (Port 80)
* **Backend API** : [http://localhost:5000](http://localhost:5000)
* **Contrôle de santé API** : [http://localhost:5000/health](http://localhost:5000/health)

Pour éteindre l'ensemble des conteneurs :
```bash
docker compose down
```

---

## 🏗️ Architecture des Services

Le projet est composé de 3 services conteneurisés interconnectés via le réseau Docker privé `paris-network` :

1. **`db` (PostgreSQL 13)** :
   * Données persistées via le volume Docker nommé `postgres_data`.
   * **Port 5432 non publié** sur l'hôte pour garantir une sécurité maximale (accès exclusif interne au réseau Docker).
   * Contrôle de santé intégré avec `pg_isready`.
2. **`backend` (API Flask - Python 3.9)** :
   * Exécuté sous un **utilisateur non-root** (`app`) pour respecter le principe du moindre privilège.
   * Démarrage ordonné : attend que la base de données soit saine (`condition: service_healthy`).
   * Expose la route de vérification `/health`.
3. **`frontend` (Interface Web - Nginx Alpine)** :
   * Sert l'interface interactive (cartes Leaflet & visualisations Chart.js).
   * Démarrage ordonné : attend que le backend soit prêt et sain.

---

## 🧪 Tests Unitaires et Rapport en Artefact

Les tests sont exécutés automatiquement dans le pipeline CI sur une matrice de versions (**Python 3.9** et **Python 3.10**) :

```bash
# Exécution locale des tests
pytest backend/tests/ -v
```

Le rapport de tests XML est automatiquement généré et archivé en tant qu'artefact téléchargeable dans GitHub Actions.

---

## 🔍 Script Bash de Contrôle Automatisé

Conformément aux exigences de l'Atelier 2, un script de contrôle vérifie l'état de santé HTTP des composants et renvoie **`0` en cas de succès**, ou un **code non-nul (1) en cas d'erreur** :

```bash
# Rendre exécutable et lancer le contrôle
chmod +x check_health.sh
./check_health.sh
```

---

## 🔄 Procédure de Retour Arrière (Rollback)

En cas de problème après le déploiement d'une version, le retour arrière vers une version précédente (ex: `v1.0.0`) est réalisé sans reconstruire le code :

```bash
# Exemple de rollback vers la version v1.0.0
chmod +x scripts/rollback.sh
./scripts/rollback.sh v1.0.0
```

---

## ⚙️ Pipeline CI/CD (GitHub Actions)

Le fichier `.github/workflows/ci-cd.yml` implémente :
1. **Validation Pull Request** : Déclenché sur chaque merge/pull request vers `master`. Exécute la matrice de tests et publie les rapports.
2. **Build & Push Docker Hub** : Conditionné au succès des tests (`needs: [test]`). Construit et tague explicitement les images (`moetezmechmech/paris-backend:vX.Y.Z`).
3. **Mise en service en environnement de test** : Télécharge les images publiées (`docker compose pull`) sans les recompiler, démarre les services et valide l'état avec `./check_health.sh`.
4. **Déploiement automatique sur tag** : Tout tag Git sous la forme `v*` (ex: `v1.0.0`) déclenche automatiquement la livraison complète.

Consultez également la [FICHE_PROJET.md](file:///c:/Users/mouez/Desktop/ParisTrees-Data-Visualization/FICHE_PROJET.md) pour le résumé d'architecture et de soutenance.
