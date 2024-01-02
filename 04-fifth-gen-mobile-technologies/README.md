# TP 4: Fifth Generation Mobile Technologies

- **Related course module**: IR.3503 - Virtual Infrastructure
- **Tutorial scope**: 5G Mobile Technologies
- **Technologies**: 5G, Linux

During this tutorial, we will learn few things like:
- What are the main NFs of the 5GC ?
- How can we deploy an end-to-end 5G system ?
- What are the main configuration elements of the 5GC ?

Voucher Link:

<a href="https://www.digitalocean.com/?refcode=ef5a5f3726df&utm_campaign=Referral_Invite&utm_medium=Referral_Program&utm_source=badge"><img src="https://web-platforms.sfo2.digitaloceanspaces.com/WWW/Badge%203.svg" alt="DigitalOcean Referral Badge" /></a>

## Prerequisites

These prerequisites only concern you if you will use a Virtual Machine (VM) on a public cloud to execute the different steps. For that, you need to have:

- an **ssh client** already configured on you desktop
- **credentials** for your VM

## Environment Setup (~30 minutes)

### Install Docker Engine

Use the official documentation to install docker engine: https://docs.docker.com/engine/install/

### Install Docker Compose

Use the official documentation to install docker compose: https://docs.docker.com/compose/install/

### Install free5gc/gtp5g kernel module

Follow the installation instructions provided here: https://github.com/free5gc/gtp5g

## Configuration (~60 minutes)

### Get free5gc-compose

Git clone the free5gc-compose project from: https://github.com/free5gc/free5gc-compose

### Explore the configuration

 1. What is the configured Public Land Mobile Network (PLMN) ID ?
 2. What are the configured 5G slices ?
 3. What are the integrity algorithms used by the Access and Mobility management Function ?
 4. What are the ciphering algorithms used by the Access and Mobility management Function ?
 5. What are the supported PLMN IDs by the AUthentication Server Function ?
 6. What is the configured Tracking Area Code for the gNodeB ?
 7. What are the 5G slices supported by the gNodeB ?
 8. What is the N2 service port of the AMF ?
 9. What is the service port of the Network Repository Function ?
 10. What is the service port of the Policy and Control Function ?
 11. What are the available Data Network Names ?
 12. What are the IP pools for each Data network in each slice ?
 13. What is the Subscription Permanent Identifier of the UE default configuration ?
 14. What are the integrity algorithms supported by the UE ?
 15. What are the ciphering algorithms supported by the UE ?

## Deployment of 5G mobile network (~30 minutes)

### NFs

Use the provided docker-compose file to deploy the following components:

  - gNB
  - NRF
  - AMF
  - SMF
  - PCF
  - NSSF
  - AUSF
  - UDM
  - UDR
  - UPF

### WebUI

Connect to the WebUI and verify that your 5GC is up and running.

## Attach a UE, capture traffic, and analyze (~60 minutes)

### UE provisionning

Provision a UE in the 5G core network using the WebUI

### Attachment procedure

Start an attachment procedure of the UE to the gNB and core network

### Analysis

Capture the application logs and the registration procedure, and analyse the protocols in use