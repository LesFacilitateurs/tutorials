# TP 3: An Introduction to Container Management and Orchestration

- **Related course module**: IR.3503 - Virtual Infrastructure
- **Tutorial scope**: Linux Containers, Container Orchestration, Life Cycle Management
- **Technologies**: Linux, Docker, Containerd, Runc, Kubernetes (k8s), k3s (lightweight kubernetes from Rancher)

The goal of this tutorial is **not to learn how to install an orchestration system**. It is rather an introduction to containized workloads management and orchestration using [Kubernetes](https://kubernetes.io/); the well established orchestration engine. This tutorial could have been done using any other orchestration platform such as, [Docker Swarm](https://docs.docker.com/engine/swarm/), [Nomad](https://www.nomadproject.io/), [Mesos](https://mesos.apache.org/), [DC/OS](https://dcos.io/), etc. (with some adaptation of course).

During this tutorial, we will learn how to:
- Deploy an application
- Manage an application's life cycle
- Make an application reachable

> In the following, you will see `Discover` if you should play around
> and see the documentation or test. You will see `Action` if you should
> run a command, write a program, or something similar. You will see `Question` when there is a question to provide an answer to.

> Note: when you find something like `<something-to-be-replaced>` it means that this is a part of the command that needs to be updated.

Voucher Link:

<a href="https://www.digitalocean.com/?refcode=ef5a5f3726df&utm_campaign=Referral_Invite&utm_medium=Referral_Program&utm_source=badge"><img src="https://web-platforms.sfo2.digitaloceanspaces.com/WWW/Badge%203.svg" alt="DigitalOcean Referral Badge" /></a>

## Prerequisites

These prerequisites only concern you if you will use a Virtual Machine (VM) on a public cloud to execute the different steps. For that, you need to:

- have an **ssh client** already configured on you desktop
- pick an **account** from the accounts csv file containing: VM's public IP address and login/password

## Before you start

I recommend that you create a text file with your favorite editor where you will continuously copy the commands and their output to help you with your TP report.

> Please note that the **VM will be destroyed** upon finishing the TP with a **grace period of 1 hour** approximately.

## Environment Setup (~30 minutes)

`Discover`

To install a Kubernetes cluster for this tutorial, we are going to setup a lightweight Kubernetes distribution called *k3s*. Application deployment on Kubernetes is simplified using Helm.

- https://kubernetes.io/
- https://k3s.io/
- https://helm.sh/docs/intro/install/

`Action`

Do the following steps:

- Install *k3s* locally on you machine
- Check the installation status (e.g. by listing your cluster nodes)
- Get the node information using the `-o wide` flag
- (Optional) Install the *dashboard* by following instructions [here](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/) and [here](https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/creating-sample-user.md)

> Note: you can enable `kubectl` auto completion using `kubectl completion`

`Question`

- How many nodes your cluster contains ?
- Which container runtime is used ?
- What are the Kubernetes *namespace* resources defined in your cluster ?
- What are the *pods* running on your cluster ?
- What are the lists of *replica sets* and *deployments* that you have on you cluster ?

`Discover`

Kubernetes *namespaces* definition could be found [here](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/)

## Deploy an Application (~45 minutes)

Before you start, launch a second terminal in which you execute the following command:

```console
watch -n1 kubectl get pods,rs,deploy,svc -A -o wide
```

Let's call this terminal the *monitoring* terminal. This is where you are going to observe the state of your cluster resources.

*Pods*, *rs*, *deploy* and *svc* are used correspondingly to list Pods, ReplicaSets, Deployments and Services. You can also add *ep* for listing Service Endpoints.

### Creating a Pod

`Action`

- Deploy *httpd* using a pod resource: `kubectl run httpd --image httpd:alpine`
- List the running *pods* in your cluster and verify that *httpd* is in "Running" state
- Inspect your *httpd* pod using `kubectl describe`

`Question`

- In which Kubernetes namespace your *httpd* pod is deployed ?

`Action`

- Delete the *httpd* pod
- Verify in the *monitoring* terminal that the pod no more exists in your cluster

### Using Manifest files

`Discover`

Kubernetes resources and controllers can be defined using manifest files written in [Yaml](https://yaml.org/). Multiple examples could be found [here](https://github.com/kubernetes/examples).

Just like in Python, indentation matters in Yaml !

`Action`

- (Optional) Install *yamllint* linter by following the instructions [here](https://github.com/adrienverge/yamllint)
- Verify if [this manifest file](manifests/httpd-namespace.yaml) is ok

In the following, you are going to manipulate more Yaml files. I recommend passing systematically each file to the linter to verify its syntax.

`Action`

- Create a Kubernetes namespace using [this namespace manifest](manifests/httpd-namespace.yaml)
- Create a Pod using [this pod manifest](manifests/httpd-pod.yaml)
- Verify in the *monitoring* terminal that your pod is correctly created under *my-httpd-namespace* namespace
- Delete the namespace

`Question`

- What happens when you delete a namespace ?

### Using Controllers

In Kubernetes, you can use controllers such as ReplicaSet, Deployments, Jobs, etc. to control the *current state* of a resource and keep it always as close as possible to the *desired state*.

`Discover`

- https://kubernetes.io/docs/concepts/workloads/controllers/

`Question`

- What is the role of the ReplicaSet controller ?
- What is the role of a Deployment controller ?

`Disover`

- https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/

In the following, you will create a ReplicaSet and a Deployment to manage the life cycle of your *httpd* Pod.

`Action`

- On your first terminal, create a ReplicaSet using the httpd replicaset manifest file located [here](manifests/httpd-replicaset.yaml)
- Observe the state of your pods and replicasets in your *monitoring* terminal
- Kill one of the *httpd replicaset pods* using: `kubectl delete pod/my-httpd-replicaset-<abcde> --namespace my-httpd-namespace`
- Observe again the state of your resources

`Question`

- What do you notice ?

`Action`

- Now **scale up** your *httpd* workload to 5 replicas using: `kubectl scale replicaset.apps/my-httpd-replicaset --replicas 5 --namespace my-httpd-namespace` and observe the state of your resources
- Then **scale down** your pod to only 2 replicas using the same command and observe the result

`Question`

- What is the role of the *ReplicaSet* controller ?

`Action`

- Delete `my-httpd-namespace` namespace to remove all resources within it
- Verify that all `my-httpd-namespace` namespace resources were wiped out

Now let's create a *Deployment* to manage the *httpd* pod.

`Discover`

- https://kubernetes.io/docs/concepts/workloads/controllers/deployment/

`Action`

- Use the *httpd* deployment manifest file located [here](manifests/httpd-deployment.yaml) to create a *Deployment*
- Update the *httpd* image version from `httpd:2.4.43-alpine` to `httpd:2.4.46-alpine` using: `kubectl edit deployment.v1.apps/my-httpd-deployment --namespace my-httpd-namespace`
- Observe the resources of your cluster on your *monitoring* terminal
- Update again the *httpd* image version from `httpd:2.4.46-alpine` to `httpd:2.4.150-alpine`
- Observe again the state of your system
- Go to the previous state by rolling back the deployment using: `kubectl rollout undo deployment.apps/my-httpd-deployment --namespace my-httpd-namespace`

`Question`

- What is the role of the *Deployment* controller ?

## Expose an Application (~30 minutes)

`Discover`

- https://kubernetes.io/docs/concepts/services-networking/service/

`Action`

The *httpd* pod is listning on the port 80 for http requests:

```console
curl <pod-replica-x-ip-address>:80
```

Do the same test using your VM public IP (you can also use your browser):

```console
curl <public-ip-address>:80
```

The pod IP address is private and only reachable from within the cluster. To make you application reachable from outside the cluster, you need to use the *Service* resource.

`Question`

- What are the different possible ways to publish a service in Kubernetes ?

`Action`

- Use the service manifest available [here](manifests/httpd-service.yaml) to create a service for your *httpd* Deployment

`Question`

- How can a service "knows" which deployment to expose ?
- What are your *httpd* service endpoints ?

`Action`

- Do the cURL test using the service Cluster IP and verify that is works
- Update the manifest file to publish the service using *NodePort* type and verify using your browser
- Update again the manifest file to use the External IPs this time

## Go further

- More on Kubernetes concepts: https://kubernetes.io/docs/concepts/
- CNCF landscape: landscape.cncf.io/
- More on k3s: https://www.youtube.com/watch?v=-HchRyqNtkU
- Flannel CNI: https://github.com/coreos/flannel

