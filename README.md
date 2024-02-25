# Continuum

Continuum est une application Java développée avec Spring Boot et Maven.

## Sommaire

- [Prérequis](#prérequis)
- [Déploiement avec Jenkins](#déploiement-avec-jenkins)
  - [Configuration automatique de Jenkins](#configuration-automatique-de-jenkins)
  - [Configuration manuelle de Jenkins](#configuration-manuelle-de-jenkins)
    - [Configuration générale](#configuration-générale)
    - [Configuration du pipeline](#configuration-du-pipeline)
  - [Lancement du pipeline](#lancement-du-pipeline)
  - [Informations supplémentaires](#informations-supplémentaires)

## Prérequis

- Java 17 ou supérieur
- Maven 3.6.0 ou supérieur
- Docker
- Jenkins
- Minikube

## Déploiement avec Jenkins

Le déploiement est géré par Jenkins via un pipeline défini dans le Jenkinsfile. Le déploiement est effectué sur un cluster Kubernetes.

### Configuration automatique de Jenkins

Un volume Docker est utilisé pour stocker les données de Jenkins. \
Un volume a déjà été créé, avec toute la configuration nécessaire pour le bon fonctionnement du pipeline.

Pour récupérer le volume Docker :
- Installer l'extension `Volumes Backup & Share` dans Docker Desktop
- Depuis l'extension, importer le volume `continuum_jenkins_volume` depuis le registre Docker Hub `docker.io/aureldp/continuum_jenkins_volume:latest`

Pour lancer Jenkins avec le volume Docker, lancer l'image jenkins avec la commande suivante :
```bash
docker run -d -p 8080:8080 -p 50000:50000 --name continuum_jenkins --mount source=continuum_jenkins_volume,target=/var/jenkins_home docker.io/jenkins/jenkins:lts
```

Les informations de connexion pour Jenkins peuvent être trouvées dans le rapport associé au projet. \
IMPORTANT: Il faudra modifier le chemin du workspace du nœud associé au pipeline

### Configuration manuelle de Jenkins

Dans le cas où le volume Docker associé au projet n'est pas disponible, il est possible de configurer manuellement Jenkins pour exécuter le pipeline. \
Vérifier que Jenkins est déjà configuré sur votre machine.

#### Configuration générale

1. Créer un nœud Jenkins avec Docker et Maven installés (labelliser ce nœud `slave`)
2. Vérifier que les plugins Kubernetes, Kubernetes CLI, Docker et Git sont installés
3. Configurer un credential (nom d'utilisateur et mot de passe) Docker `dockerhub_id` pour se connecter à Docker Hub
4. Configurer un credential (SSH username with private key) Github `github_id` pour se connecter à Github

#### Configuration du pipeline

1. Créer un nouveau pipeline `ContinuumDeploymentPipeline` dans Jenkins
2. Configurer le pipeline avec le contenu du Jenkinsfile
3. Lancer le nœud Jenkins `slave` pour exécuter le pipeline

### Lancement du pipeline

Après avoir configuré Jenkins, il est possible de lancer le pipeline `ContinuumDeploymentPipeline` pour déployer l'application sur un cluster Kubernetes.

1. Lancer minikube avec la commande `minikube start` pour démarrer le cluster Kubernetes
2. Lancer le pipeline `ContinuumDeploymentPipeline` dans Jenkins
3. Vérifier que le déploiement a été effectué avec succès avec la commande `kubectl get all -n production`
4. Vérifier que l'application est accessible à l'adresse `http://localhost:8082` (port correspondant à l'application en mode production)
   - Le pipeline Jenkins effectue déjà une redirection de port automatique, mais elle s'arrête à la fin du pipeline
   - La redirection de port peut être effectuée avec la commande `kubectl port-forward svc/continuum-service 8082:8082 -n production`
   - Il est également possible d'utiliser la commande `minikube tunnel` pour exposer le service à l'extérieur du cluster Kubernetes sans avoir à rediriger le port

## Informations supplémentaires

- L'application est accessible au port 8081 en mode développement et au port 8082 en mode production
- Les informations de connexion Github et Docker Hub sont disponibles dans le rapport associé au projet
