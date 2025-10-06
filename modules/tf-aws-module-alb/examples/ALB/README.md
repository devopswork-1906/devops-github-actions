# Application Load Balancer with ACM, Multiple Listeners, and Auto Scaling

## Table of Contents

- [Overview](#overview)
- [Features](#Features)
- [Requirements](#Requirements)
- [Usage](#usage)
  - [Application Load Balancer](#application-load-balancer)
- [Inputs](#inputs)
- [Outputs](#outputs)
- [Notes](#notes)

## Overview

This example demonstrates how to deploy a production-grade AWS Application Load Balancer (ALB) with multiple listeners, ACM certificates, Auto Scaling Groups, and target groups. It covers common real-world use cases, including HTTPS termination, multiple certificates, target group routing, and integration with both Auto Scaling Groups and standalone instances. Also, it has multiple listener role to route traffic based on conditions defined.

## Features

This example provisions:
- ACM Certificates
  - Primary certificate for the ALB.
  - Additional certificate for multi-domain support.
- Application Load Balancer
  - ALB deployed across multiple subnets.
  - HTTP listener (port 80) → redirect to HTTPS.
  - HTTPS listener (port 443) with default and additional ACM certificates.
  - Multiple Listener rules with multiple target groups( forward, redirect and fixed response).
  - Weighted forwarding, round-robin forwarding.
  - Multiple conditions for listner rule lile http_header, query_string, path_pattern, host_header, source_ip, http_request_method, routing.
- Target Groups
  - Auto Scaling Group (ASG) of EC2 instances (dynamic backend).
  - Standalone EC2 instances (static backend).
  - Health checks configured per TG.
  - Additional target group attachmennt
- Auto Scaling
  - Launch template and ASG.
  - Scaling policies (CPU target scaling).
  - Example lifecycle policies.
- Outputs
  - ALB DNS name.
  - Target group ARNs.
  - Auto Scaling Group name.
  - Launch template details

---

## Requirements

| Name         | Version   |
|--------------|-----------|
| Terraform    | >= 1.5.6  |
| AWS Provider | >= 5.22   |

## 