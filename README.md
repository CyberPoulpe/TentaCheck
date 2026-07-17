# TentaCheck

Ce script PowerShell interroge un serveur **WSUS** pour identifier les mises à jour récentes qui sont **non approuvées** et **non déclinées**. Il permet ensuite d'ouvrir automatiquement leurs fiches descriptives correspondantes sur le catalogue public de **NinjaOne** en appliquant une temporisation pour préserver les ressources système.

## 📋 Fonctionnalités

* **Filtrage natif WSUS** : Requête optimisée directement sur la base WSUS pour récupérer uniquement les éléments non approuvés.
* **Filtre temporel ajustable** : Permet de cibler uniquement les mises à jour récentes (ex. 60 derniers jours) pour écarter les KB obsolètes.
* **Extraction et dédoublonnement** : Parse les titres des mises à jour pour en extraire des numéros de KB uniques.
* **Ouverture temporisée** : Ajoute un délai configurable (ex. 5 secondes) entre l'ouverture de chaque onglet dans le navigateur par défaut pour éviter de saturer la machine.
* **Sécurité anti-surcharge** : Demande confirmation ou limite le nombre d'onglets à ouvrir si la liste de KB est trop importante.

---

## 🛠️ Prérequis

* **PowerShell 5.1 ou supérieur**.
* Le module Windows Server **`UpdateServices`** installé sur la machine exécutant le script.
* Les privilèges réseau et d'accès requis pour interroger le serveur WSUS cible sur son port d'administration.

---

## ⚙️ Configuration du script

Les variables de configuration se trouvent en tête de script et peuvent être adaptées à votre environnement :

```powershell
$ServerName = "VOTRE-SERVEUR-WSUS"  # Nom d'hôte ou IP du WSUS
$Port = 8530                       # Port d'écoute (généralement 8530 ou 8531 pour HTTPS)
$NbJoursEnArriere = 60             # Profondeur de l'historique en jours
$DelaiEntrePages = 5               # Temps d'attente (en secondes) entre deux ouvertures d'onglets
