# Deploying the Alteon VA in Azure - Single IP

[![Issues](https://img.shields.io/github/issues/Radware/Radware-azure-arm-templates)](https://github.com/radware/Radware-azure-arm-templates/issues)
[![Commit](https://img.shields.io/github/last-commit/Radware/Radware-azure-arm-templates)]()


## Contents

- [Introduction](#introduction)
- [Prerequisites](#prerequisites)
- [ Configuration Notes](#important-configuration-notes)
- [Deployment](#Deployment)

## Introduction

This solution uses an ARM template to launch a single NIC deployment of a cloud-focused Alteon VA in Microsoft Azure. Traffic flows from the Alteon VA to the application servers. This is the standard Cloud design where the  Alteon VA instance is running with a single interface, where both management and data plane traffic is processed.  This is a traditional model in the cloud where the deployment is considered one-armed.

The Alteon VA provide advanced application delivery features.

For information on getting started using Alteon on Azure [Alteon in Azure] (https://support.radware.com/app/answers/answer_view/a_id/20942/related/1).

**Networking  Type:** This solution deploys into a new networking, which is created along with the solution.
