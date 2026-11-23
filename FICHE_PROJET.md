# Fiche Projet DevOps — ParisTrees Visualization

**Étudiant :** Moetez Mechmech  
**Module :** DevOps — Licence 3 DSI (ISET)  
**Projet :** Chaine d'intégration et déploiement continu complète  
**Dépôt Git :** [https://github.com/moetezmechmech/projet_devops.git](https://github.com/moetezmechmech/projet_devops.git)  

### Liens des exécutions du pipeline (Exigés pour le rendu) :
* 🟢 **Exécution réussie (Pipeline vert) :** [https://github.com/moetezmechmech/projet_devops/actions/runs/45225703015](https://github.com/moetezmechmech/projet_devops/actions/runs/45225703015)
* 🔴 **Exécution en échec (Pipeline rouge) :** [https://github.com/moetezmechmech/projet_devops/actions/runs/45225700311](https://github.com/moetezmechmech/projet_devops/actions/runs/45225700311)  

---

## 1. Architecture du Système

Le projet est composé d'une architecture multi-services conteneurisée et orchestrée par **Docker Compose** au sein d'un réseau privé isolé (`paris-network`) :

```
                        [ Utilisateur / Navigateur ]
                                     |
                                  Port 80
                                     v
                       +---------------------------+
                       |    Frontend (Nginx)       |
                       |  Image: :latest / :vX.Y.Z |
                       +---------------------------+
                                     |
                                 Port 5000
                                     v
                       +---------------------------+
                       |   Backend API (Flask)     |
                       |  Image: :latest / :vX.Y.Z |
                       |    Endpoints: /health     |
                       +---------------------------+
                                     |
                       Réseau interne Docker (Port 5432)
                       (Port NON publié sur l'hôte)
                                     v
                       +---------------------------+
                       |   Database (PostgreSQL)   |
                       |    Volume: postgres_data  |
                       +---------------------------+
```

### Règles de sécurité et robustesse appliquées :
* **Isolation stricte de la base de données :** Le port `5432` n'est **pas publié** sur la machine hôte ; seuls les services internes du réseau Docker peuvent y accéder.
* **Ordonnancement conditionné à la santé (`healthcheck`) :**
  1. PostgreSQL démarre et valide son état de santé via `pg_isready`.
  2. Le Backend attend que la DB soit saine (`condition: service_healthy`) avant de s'exécuter.
  3. Le Frontend attend que le Backend réponde avec succès sur `/health` avant d'accepter le trafic.
* **Moindre privilège :** Le conteneur Backend s'exécute sous un utilisateur non-root (`app`).

---

## 2. Version Mise en Service

* **Version active de production / test :** `v1.0.0`
* **Registres d'images Docker Hub :**
  * `moetezmechmech/paris-backend:v1.0.0`
  * `moetezmechmech/paris-frontend:v1.0.0`
* **Règle d'immuabilité :** Une image produite par le pipeline CI porte un tag sémantique explicite `vX.Y.Z` et n'est **jamais reconstruite** lors du déploiement (déploiement exclusivement par `docker compose pull` et `docker compose up -d --no-build`).

---

## 3. Déroulé du Retour Arrière (Rollback)

En cas d'anomalie détectée après la mise en service d'une nouvelle version (ex: régression sur `v1.0.1`), la procédure de retour arrière vers la version saine précédente (`v1.0.0`) est instantanée et reproductible.

### Procédure automatique via le script :
```bash
./scripts/rollback.sh v1.0.0
```

### Déroulement technique sous-jacent :
1. **Spécification de la version cible :** `export APP_VERSION=v1.0.0`
2. **Téléchargement sans re-compilation :**
   ```bash
   docker compose pull backend frontend
   ```
3. **Redémarrage à chaud :**
   ```bash
   docker compose up -d --no-build backend frontend
   ```
4. **Validation de l'état de santé :**
   ```bash
   ./check_health.sh
   ```
   Le script exécute des requêtes sur `http://localhost:5000/health` et `http://localhost:80/` et retourne le code `0` attestant du retour réussi à la version stable.

---

## 4. Points Clés pour la Soutenance (10 min)

1. **Merge Request / Pull Request :** Démonstration d'une PR verte (tests unitaires passés + rapport XML sauvegardé en artefact) et d'une PR rouge (avec affichage de la première erreur utile dans les logs).
2. **Déploiement sur Tag :** Publication du tag `git tag v1.0.0 && git push origin v1.0.0` déclenchant la livraison et le contrôle de santé automatique.
3. **Protection de la branche principale :** Règle GitHub interdisant le merge si le job `test` n'est pas vert.
