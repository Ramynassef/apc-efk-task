# EFK-Minikube Setup by Terraform

## Introduction

Repository used to create **E**lasticsearch, **F**luentd, and **K**ibana (EFK) stack on Minikube via Terraform (kubernetes_manifest).

**Elasticsearch** is a real-time, distributed, and scalable search engine which allows for full-text and structured search, as well as analytics. It is commonly used to index and search through large volumes of log data, but can also be used to search many different kinds of documents.

Elasticsearch is commonly deployed alongside **Kibana**, a powerful data visualization frontend and dashboard for Elasticsearch. Kibana allows you to explore your Elasticsearch log data through a web interface, and build dashboards and queries to quickly answer questions and gain insight into your Kubernetes applications.

**Fluentd** is used to collect, transform, and ship log data to the Elasticsearch backend. Fluentd is a popular open-source data collector that we’ll set up on our Kubernetes nodes to tail container log files, filter and transform the log data, and deliver it to the Elasticsearch cluster, where it will be indexed and stored.

We’ll begin by configuring and launching an Elasticsearch cluster, and then create the Kibana Kubernetes Service and Deployment. To conclude, we’ll set up Fluentd as a DaemonSet so it runs on every Kubernetes worker node.

## Table of Contents

- [EFK-Minikube Setup by Terraform](#efk-minikube-setup-by-terraform)
  - [Introduction](#introduction)
  - [Table of Contents](#table-of-contents)
    - [Minikube Installation](#minikube-installation)
    - [Terraform Code](#terraform-code)
    - [Managing Minikube](#managing-minikube)
    - [Enabling Retention Period on Kibana](#enabling-retention-period-on-kibana)


### Minikube Installation

Prerequiests steps on Ubuntu 18.04:
+ Install Docker
+ Install Minikube
+ Install Kubectl
+ Start Minikube
  
```bash 
minikube start --driver=docker --kubernetes-version=stable 
```

![](https://github.com/Ramynassef/apc-efk-task/blob/main/images/minikube-install.png)

+ Check Minikube Status
  
```bash 
kubectl get nodes
```

![](https://github.com/Ramynassef/apc-efk-task/blob/main/images/minikube-status.png)

### Terraform Code
We're deploying the EFK on Minikube as per the following TF files:

**1- Creating a Namespace**

```bash
resource "kubernetes_manifest" "namespace_kube_logging" {
  manifest = {
    "apiVersion" = "v1"
    "kind"       = "Namespace"
    "metadata" = {
      "name" = "kube-logging"
    }
  }
}
```

**2- Creating the Elasticsearch StatefulSet** 

Now that we’ve created a Namespace to house our logging stack, we can begin rolling out its various components. We’ll first begin by deploying a single-node Elasticsearch cluster for our current demo.

We'll start with a headless Kubernetes service called `elasticsearch`

```bash
resource "kubernetes_manifest" "service_kube_logging_elasticsearch" {
  depends_on = [kubernetes_manifest.namespace_kube_logging]
  manifest = {
    "apiVersion" = "v1"
    "kind"       = "Service"
    "metadata" = {
      "labels" = {
        "app" = "elasticsearch"
      }
      "name"      = "elasticsearch"
      "namespace" = "kube-logging"
    }
    "spec" = {
      "clusterIP" = "None"
      "ports" = [
        {
          "name" = "rest"
          "port" = 9200
        },
        {
          "name" = "inter-node"
          "port" = 9300
        },
      ]
      "selector" = {
        "app" = "elasticsearch"
      }
    }
  }
}
```
> elasticsearch_svc.tf File

A Kubernetes StatefulSet allows you to assign a stable identity to Pods and grant them stable, persistent storage. Elasticsearch requires stable storage to persist data across Pod rescheduling and restarts. `elasticsearch_statefulset.tf` is using just one-node (Master), then identifying the `Docker Image` , ports, container resources such as CPU & the heap size, `volumeMount`, and the bottom of the file the `volumeClaimTemplate` block.

**3- Creating the Kibana Deployment and Service** 

To launch Kibana on Kubernetes, we’ll create a Service called `kibana` in `kibana.tf`, and a Deployment consisting of one Pod replica.

**4- Creating the Fluentd DaemonSet** 

We’ll set up Fluentd as a **DaemonSet**, which is a Kubernetes workload type that runs a copy of a given Pod on each Node in the Kubernetes cluster. 

Here, we create a Service Account called fluentd that the Fluentd Pods will use to access the Kubernetes API. We create it in the `kube-logging` Namespace and once again give it the label `app: fluentd`.

```bash
resource "kubernetes_manifest" "serviceaccount_kube_logging_fluentd" {
  manifest = {
    "apiVersion" = "v1"
    "kind"       = "ServiceAccount"
    "metadata" = {
      "labels" = {
        "app" = "fluentd"
      }
      "name"      = "fluentd"
      "namespace" = "kube-logging"
    }
  }
}
```

We define a ClusterRole called fluentd to which we grant the get, list, and watch permissions on the pods and namespaces objects. ClusterRoles allow you to grant access to cluster-scoped Kubernetes resources like Nodes. We also define a `ClusterRoleBinding` called fluentd which binds the fluentd ClusterRole to the fluentd Service Account. This grants the fluentd ServiceAccount the permissions listed in the fluentd Cluster Role.

**4- Running Terraform Commands** 

We start running `terraform init` 

![](https://github.com/Ramynassef/apc-efk-task/blob/main/images/tf-init.png)

then `terrform apply`

![](https://github.com/Ramynassef/apc-efk-task/blob/main/images/tf-apply.png)


### Managing Minikube

We'll run the below command to check the status of each pod:

`kubectl get pods -n kube-logging`

![](https://github.com/Ramynassef/apc-efk-task/blob/main/images/pods.png)

> counter pod is used for testing. However, it's optional as Fluentd is already fetching all the pods logs in the cluster

We need to post-forward the Kibana port, to be able to open it locally from the browser

`kubectl port-forward <KIBANA-POD> 5601:5601 –n kube-logging`

Then, create an index from Kibana Dashboard

### Enabling Retention Period on Kibana

We'll open Kibana locally from the broswer on `http://localhost:5601`, then go to the settings at the bottom of the page and press on `Index Lifecycle Policies`. Afterwards, create a policy to delete the logs, which is lifetime is one day.

![](https://github.com/Ramynassef/apc-efk-task/blob/main/images/policy.png)

![](https://github.com/Ramynassef/apc-efk-task/blob/main/images/policy1.png)

Here, we're can find the logs of the different pods on Kibana

![](https://github.com/Ramynassef/apc-efk-task/blob/main/images/elk-result.png)