# TP 5: Simple CNF Deployment

  - **Related course module**: IR.3503 - Virtual Infrastructure
  - **Tutorial scope**: 5G Mobile Technologies
  - **Technologies**: 5G, Linux

Voucher Link:

<a href="https://www.digitalocean.com/?refcode=ef5a5f3726df&utm_campaign=Referral_Invite&utm_medium=Referral_Program&utm_source=badge"><img src="https://web-platforms.sfo2.digitaloceanspaces.com/WWW/Badge%203.svg" alt="DigitalOcean Referral Badge" /></a>

## Prerequisites

These prerequisites only concern you if you will use a Virtual Machine (VM) on a public cloud to execute the different steps. For that, you need to have:

  - an **ssh client** already configured on you desktop
  - **credentials** for your VM

## Environment Setup (~1h)

### Install a Kubernetes cluster

There are multiple options to install a [Kubernetes](https://kubernetes.io/) cluster. Some of them are listed below. You can deploy your cluster using one of the following options:

  - k3s - https://k3s.io/
  - Minikube - https://minikube.sigs.k8s.io/docs/start/
  - Kind - https://kind.sigs.k8s.io/docs/user/quick-start/
  - Kubeadm - https://kubernetes.io/docs/reference/setup-tools/kubeadm/

More information on how to setup a Kubnertes cluster for different purposes (learning, testing, development, production, etc) can be found here: https://kubernetes.io/docs/setup/

> Depending on the option you choose, you might need to install other dependencies

> Also note that the requested cluster is mono-node. You can choose to create a multi-node cluster using multiple VMs (Optional)

### Cluster Deployment Verification

After you finish deploying your cluster, deploy an `Nginx` sample application `Pod` and test it's reachability.

## Performace Test Using iPerf3 (~2h)

The CNF we need to deploy is [iPerf3](https://github.com/esnet/iperf) which is a tool for active measurements of the maximum achievable bandwidth on IP networks.

### Reading the docs

Please refer to iPerf3 CLI documentation [here](https://manpages.ubuntu.com/manpages/xenial/man1/iperf3.1.html) and answer the following questions:

  - What is the default iPerf3 server port ?
  - What is the purpose of the `-A` option ?
  - When is it preferred to use the background mode for the iPerf3 server ?
  - Which 3 transport protocols are tested using iPerf3 ?
  - How to set the maximum throughput for a given test ?


### Test Execution

Our goal is to deploy an `iPerf3` server and client CNFs, and execute some tests.

The steps needed to reach this goal are:

  - Select an `iPerf3` docker image (e.g. https://hub.docker.com/r/sofianinho/iperf3)
  - Create a deployment manifest
  - Deploy 2 `iPerf3` `Pods` on your K8s cluster
  - Start an `iPerf3` server
  - Start an `iPerf3` client
  - Launch a network performance test using `TCP`
  - Launch a network performance test using `UDP`