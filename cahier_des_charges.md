# Cahier des charges — Application de gestion des réclamations internes d'hôtel

## 1. Présentation générale

### 1.1. Contexte
La gestion efficace des réclamations internes est un enjeu majeur pour le bon fonctionnement d'un hôtel. Ce projet vise à digitaliser et centraliser la gestion des réclamations faites par le personnel, afin d'améliorer la réactivité, la traçabilité et la résolution des incidents.

### 1.2. Objectifs
- Permettre au personnel de signaler rapidement tout problème ou besoin d'intervention.
- Offrir aux administrateurs une vision globale et analytique des réclamations.
- Optimiser la communication entre les différents départements.
- Suivre l'évolution et la résolution des réclamations en temps réel.

## 2. Parties prenantes
- **Staff hôtelier** : création et suivi de réclamations.
- **Administrateurs** : gestion, analyse, statistiques, affectation.
- **Managers/Responsables** : supervision, reporting.
- **Développeurs** : maintenance et évolution de la solution.

## 3. Fonctionnalités principales

### 3.1. Authentification & Sécurité
- Connexion sécurisée (nom d'utilisateur et mot de passe).
- Gestion des rôles : staff, admin.
- Stockage sécurisé des informations sensibles.

### 3.2. Gestion des utilisateurs
- Création, modification, suppression d'utilisateurs (admin).
- Attribution de rôles et de départements.
- Vérification de l'unicité des emails.

### 3.3. Gestion des réclamations
- Création d'une réclamation (objet, description, département(s), priorité, emplacement).
- Affectation automatique ou manuelle à un staff.
- Suivi des statuts : New, In Progress, Done.
- Modification et suppression par l'auteur ou l'admin.
- Historique des actions et des modifications.

### 3.4. Tableaux de bord & Statistiques
- Vue synthétique pour l'admin : nombre de réclamations par statut, par département, par période.
- Graphiques d'évolution mensuelle, répartition par priorité, etc.
- Liste filtrable et triable des réclamations.

### 3.5. Notifications
- Notification par email lors de la création d'une réclamation.
- Notification en temps réel (WebSocket) pour les mises à jour.

### 3.6. Filtres et recherche
- Recherche par nom, email, département, statut, période, priorité.
- Filtres combinés pour affiner l'affichage.

### 3.7. Sécurité & RGPD
- Protection des données personnelles.
- Accès restreint selon le rôle.
- Journalisation des actions sensibles.

## 4. Architecture technique

### 4.1. Frontend (mobile Flutter)
- Application Flutter compatible Android (et potentiellement iOS/web).
- Navigation par onglets (dashboard, réclamations, utilisateurs).
- Formulaires dynamiques et validés.
- Gestion de l'état avec setState et FutureBuilder.
- Appels API REST sécurisés.

### 4.2. Backend (Node.js + Express)
- API RESTful structurée.
- Contrôleurs séparés pour chaque entité (utilisateur, réclamation).
- Modèles Mongoose pour MongoDB.
- Gestion des routes, middlewares, CORS.
- WebSocket (Socket.io) pour le temps réel.
- Envoi d'emails (Nodemailer).

### 4.3. Base de données
- MongoDB Atlas (cloud) ou local.
- Collections : users, reclamations.
- Indexation sur les champs critiques (email, statut, département).

## 5. Technologies utilisées
- **Frontend** : Flutter, Dart
- **Backend** : Node.js, Express.js
- **Base de données** : MongoDB (Mongoose)
- **WebSocket** : Socket.io
- **Email** : Nodemailer
- **Déploiement** : Render, Vercel, MongoDB Atlas
- **Outils** : Postman, Git, VSCode

## 6. Sécurité
- Hashage des mots de passe (à prévoir en production).
- Validation des entrées côté client et serveur.
- Gestion des erreurs et des statuts HTTP.
- CORS configuré.
- Variables d'environnement pour les secrets.

## 7. Tests & Qualité
- Tests manuels des parcours critiques (création, modification, suppression, filtrage).
- Vérification de la robustesse des formulaires.
- Contrôle de la réactivité de l'interface.
- Tests d'intégration API avec Postman.

## 8. Déploiement & Maintenance
- Déploiement du backend sur Render (ou équivalent).
- Déploiement du frontend sur le store Android (ou Vercel pour la webapp).
- Documentation du code (commentaires détaillés partout).
- Procédures de sauvegarde et restauration de la base.
- Possibilité d'évolution (ajout de modules, internationalisation, etc.).

## 9. Contraintes & recommandations
- Interface claire, moderne, responsive.
- Temps de réponse < 2s pour chaque action.
- Accessibilité (contrastes, tailles de police).
- Respect du RGPD.
- Prévoir la scalabilité (multi-hôtels possible à terme).

## 10. Livrables
- Code source complet (frontend + backend).
- Cahier des charges (ce document).
- Documentation technique (commentaires dans le code).
- Procédure d'installation et de déploiement.
- Présentation pour la soutenance.

---

**Ce cahier des charges est exhaustif et couvre tous les aspects fonctionnels, techniques et organisationnels du projet de gestion des réclamations internes d'hôtel.** 