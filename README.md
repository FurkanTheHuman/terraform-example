# Deploying a Kubernetes Cluster on AWS with terraform eks provider.

## Prerequisites

- AWS account
- AWS CLI
- Terraform
- kubectl

## Steps

1. Create an IAM user with programmatic access and AdministratorAccess policy attached.
2. Configure AWS CLI with the credentials of the user created in the previous step.
3. Provide a profile name in the variables.tf file. And remember to provide an s3 backend for terraform state in main file.
4. Run `terraform init` to initialize the terraform directory.
5. Run `terraform plan` to see the resources that will be created.
6. Run `terraform apply` to create the resources.
7. Run `aws eks update-kubeconfig --name midas-cluster  --profile <profile_name>` to configure kubectl to use the cluster.
8. Check the `project` namespace since deployments are created in that namespace.

## predefined ip

cluster is behinda a nat gateway. and you can see the ip of it in the outputs of the terraform apply or you can run `terraform output nat_gateway_ip` to see the ip of the nat gateway.

## Accesing the application

The deployed application uses a fake frontend and backend. To query the load balancer DNS name, run `kubectl get svc | grep Load`. Copy the External IP. And then run `curl <external_ip> -H "project.example.com"` to see the response from the application. Which should be a welcome message from nginx. Backend is not configured to be publicly accessible. So you can't query it from outside the cluster.

## Details of the application

project has many stateless replicas in the cluster to show high availability and should be extremely easy to scale up or down. A possible TODO would be adding a horizontal pod autoscaler to the deployment. Which is trivial to do with the current setup.
