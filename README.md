# Continuum

Continuum is a Java application developed with Spring Boot and Maven.

---

## Summary

- [Prerequisites](#prerequisites)
- [Deployment with Jenkins](#deployment-with-jenkins)
    - [Automatic Jenkins configuration](#automatic-jenkins-configuration)
    - [Manual Jenkins configuration](#manual-jenkins-configuration)
        - [General configuration](#general-configuration)
        - [Pipeline configuration](#pipeline-configuration)
    - [Pipeline launch](#pipeline-launch)
- [Monitor the application with Prometheus and Grafana](#monitor-the-application-with-prometheus-and-grafana)
    - [Installing Prometheus and Grafana](#installing-prometheus-and-grafana)
    - [Accessing Prometheus and Grafana](#accessing-prometheus-and-grafana)
    - [Using Grafana](#using-grafana)
- [Additional information](#additional-information)

## Prerequisites

- **Java 17** or higher
- **Maven 3.6.0** or higher
- **Docker**
- **Jenkins 2.444** or higher
- **Minikube**
- **Helm**

> [!IMPORTANT]
> Make sure that you can execute `sh` commands in your terminal as Jenkinsfile uses shell commands. \
> To enable it with git on **Windows**, please **replace the path** `C:\Program Files\Git\bin` with `C:\Program Files\Git\usr\bin` (or equivalent if
> git is installed to another location)
> in the system environment variable `Path` and **restart your terminal** (or the node's terminal for **Jenkins**).

---

## Deployment with Jenkins

The deployment is managed by **Jenkins** via a pipeline defined in the Jenkinsfile. The deployment is done on a **Kubernetes cluster**. \
To configure **Jenkins**, you can choose the **automatic configuration** with a **Docker volume** or the **manual configuration**.

### Automatic Jenkins configuration

A Docker volume is used to store Jenkins data. \
A volume has already been created, with all the necessary configuration for the pipeline to work properly.

To retrieve the Docker volume:

- Install the `Volumes Backup & Share` extension in **Docker Desktop**
- From the extension, import the volume from the **Docker Hub registry** `docker.io/aureldp/continuum_jenkins_volume:latest` and name
  it `continuum_jenkins_volume`

To start Jenkins with the Docker volume, run the Jenkins image with the following command:

```bash
docker run -d -p 8080:8080 -p 50000:50000 --name continuum_jenkins --mount source=continuum_jenkins_volume,target=/var/jenkins_home docker.io/jenkins/jenkins:2.444
```

> [!IMPORTANT]
> Make sure to use a version of **Jenkins** equal to or greater than **2.444**.

The connection information for Jenkins can be found in the report associated with the project.

> [!NOTE]
> The workspace path of the `slave` node associated with the pipeline will need to be modified in the **Jenkins node configuration**.

### Manual Jenkins configuration

In the case where the Docker volume associated with the project is not available or not working, it is possible to **manually configure Jenkins** to
run the pipeline. \
Make sure Jenkins is **already configured** on your machine.

#### General configuration

1. Create a Jenkins node with Docker and Maven installed (**label this node** `slave`)
    - If the workspace of the node is on your local machine, **Docker** and **Maven** must be installed on it
2. Make sure that the **Kubernetes**, **Kubernetes CLI**, **Docker**, **Docker Pipeline** and **Git** plugins are installed
3. Configure a **Docker credential** (username and password) `dockerhub_id` to connect to Docker Hub
    - The connection information for **Docker Hub** can be found in the report associated with the project

#### Pipeline configuration

1. Create a new pipeline `ContinuumDeploymentPipeline` in Jenkins
2. Configure the pipeline with the content of the [Jenkinsfile](https://github.com/AurelDP/Continuum/blob/main/ops/Jenkinsfile)
3. Start the Jenkins node `slave` to run the pipeline

### Pipeline launch

After configuring Jenkins, it is possible to launch the `ContinuumDeploymentPipeline` pipeline to deploy the application on a **Kubernetes cluster**.

1. **Start minikube** with the command `minikube start`
2. Run the `ContinuumDeploymentPipeline` pipeline in Jenkins
3. Check that the deployment was successful with the command:
    ```bash
    kubectl get all -n production
    ```
4. Check that the **application is accessible** at http://localhost:8082 (port in production mode)
    - **Port forwarding** can be done with the command:
         ```bash
         kubectl port-forward svc/continuum-service 8082:8082 -n production
         ```
    - It is also possible to use the command `minikube tunnel` to expose the service outside the Kubernetes cluster without having to forward the port

---

## Monitor the application with Prometheus and Grafana

To monitor the application, **Prometheus** and **Grafana** are used.

### Installing Prometheus and Grafana

**Prometheus** and **Grafana** are installed with **Helm**. \
Run the script [install-monitoring.sh](https://github.com/AurelDP/Continuum/blob/main/ops/install-monitoring.sh) to install **Prometheus** and 
**Grafana** on the Kubernetes cluster.

```bash
sh ops/install_monitoring.sh
```

> [!NOTE]
> **Helm** must be installed on your machine to run the script and **Minikube** must be started.

### Accessing Prometheus and Grafana

Run the script [launch-monitoring.sh](https://github.com/AurelDP/Continuum/blob/main/ops/launch-monitoring.sh) to access **Prometheus** and 
**Grafana**:

```bash
sh ops/launch_monitoring.sh
```

> [!NOTE]
> Port forwarding is done automatically with the script, please do not close the terminal while using the monitoring tools.

### Using Grafana

1. Access **Grafana** at http://localhost:3000
2. Log in with the following credentials:
    - **Username**: admin
    - **Password**: password given by the launching script
3. Datasource to Prometheus is already configured with the installation script. If not, add a new datasource with the following information:
    - **Name**: Prometheus
    - **Type**: Prometheus
    - **Connection URL**: http://host.docker.internal:9090
4. Dashboard is already imported with the installation script. If not, import the **dashboard** from the
   file [dashboard.json](https://github.com/AurelDP/Continuum/blob/main/ops/grafana/dashboard.json)
5. Alerts are already imported with the installation script.

---

## Additional information

- The application is accessible at port **8081** in development mode and at port **8082** in production mode
- The connection information for **Docker Hub** can be found in the report associated with the project
