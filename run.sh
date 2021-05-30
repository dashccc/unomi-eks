#!/bin/bash

# create EKS cluster
eksctl create cluster -f eks-cluster.yml

# config kubectl
aws eks --region us-west-1 update-kubeconfig --name unomi-cluster

# test configuration
kubectl get svc

