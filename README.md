# Trigger Lambda from S3

This is a sample project that demonstrates how to create an S3 bucket in AWS using Terraform and configure two Lambda functions to be triggered whenever an object is created or deleted in specific folders.

## Prerequisites

Before you begin, make sure you have the following:

- An AWS account
- Terraform installed on your local machine
- AWS CLI configured with your AWS credentials

## Getting Started

Follow the steps below to set up and deploy the project:

1. Clone this repository to your local machine.
2. Navigate to the project directory: `cd trigger_lambda_from_s3`.
3. Initialize the Terraform configuration: `terraform init`.
4. Modify the files to customize the S3 bucket and Lambda functions according to your requirements.
5. Apply the Terraform configuration: `terraform apply`.
6. Confirm the changes and wait for the resources to be provisioned.
7. Test the setup by uploading or deleting objects in the specified folders in the S3 bucket.
