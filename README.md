```markdown
# Terraform AWS S3 & CloudFront Infrastructure

This Terraform project provisions an AWS infrastructure that includes S3 buckets and a CloudFront distribution. We can use this Terraform script for deplpying a static website to Cloudfront with S3 as origin. It will also create bucket policy, if website is deployed and still you are not able to access your site, then manually create origin access identity with same S3 from console, and update it in S3 policy & remove old S3 policy. The project is modular and uses two modules:
- **S3 Module**: Provisions an AWS S3 bucket with specific settings.
- **CloudFront Module**: Provisions an AWS CloudFront distribution with an origin that points to the S3 bucket.

## Directory Structure

```bash
terraform-project/
│
├── Cloudfront/
│   ├── main.tf                # CloudFront resource definitions
│   ├── outputs.tf             # CloudFront outputs
│   └── variables.tf           # CloudFront variables
│
├── S3/
│   ├── main.tf                # S3 resource definitions
│   ├── outputs.tf             # S3 outputs
│   └── variables.tf           # S3 variables
│
├── modules/
│   ├── main.tf                # Main file calling both S3 and CloudFront modules
│   ├── outputs.tf             # Combined outputs of both modules
│   └── variables.tf           # Variables required for both modules
│
└── README.md                  # Project documentation
```

## How to Use

### Prerequisites
- [Terraform](https://www.terraform.io/downloads.html) must be installed.
- AWS credentials should be configured in your environment, either using the AWS CLI (`aws configure`) or environment variables (`AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`).

### Steps

1. **Clone the repository**:
    ```bash
    git clone <repository_url>
    cd terraform-project
    ```

2. **Initialize Terraform**:
    This step downloads the necessary provider plugins and initializes the working directory containing the Terraform configuration files.
    ```bash
    terraform init
    ```

3. **Customize Variables**:
    Modify the variables in `modules/variables.tf` to suit your environment. Here’s an example of the variables you might set:
    ```hcl
    variable "s3_bucket_name1" {
      default = "my-s3-bucket-name"
    }

    variable "s3_tag1" {
      default = "my-s3-tag"
    }

    variable "s3_env1" {
      default = "production"
    }

    variable "cloudfront_description1" {
      default = "CloudFront distribution for my S3 bucket"
    }
    ```

4. **Run Terraform Plan**:
    Review the execution plan to see the changes that Terraform will apply.
    ```bash
    terraform plan
    ```

5. **Apply the Configuration**:
    Apply the Terraform configuration to create the AWS resources.
    ```bash
    terraform apply
    ```

6. **Check the Outputs**:
    After a successful deployment, Terraform will display output values, including the CloudFront distribution domain and the S3 bucket names.

    Example:
    ```bash
    cloudfront_distribution_id = "E1234567890"
    cloudfront_distribution_arn = "arn:aws:cloudfront::123456789012:distribution/E1234567890"
    s3_bucket_names = {
      "resource-1" = "my-s3-bucket-name"
    }
    ```

### Cleaning Up
To remove the infrastructure created by Terraform, you can run the following command:
```bash
terraform destroy
```

## Components

### S3 Module
The **S3 module** provisions an S3 bucket and applies basic settings such as forceful bucket deletion and public access block settings.

### CloudFront Module
The **CloudFront module** provisions a CloudFront distribution with S3 as the origin. The CloudFront distribution is configured to serve content securely, with HTTPS enforcement.

## Variables

The project uses several variables to customize the deployment. These are defined in `modules/variables.tf`. You can modify these values as per your environment.

- `s3_bucket_name1`: Name of the first S3 bucket.
- `s3_tag1`: Tag for the S3 bucket.
- `s3_env1`: Environment for the S3 bucket (e.g., production, staging).
- `cloudfront_description1`: Description for the CloudFront distribution.

## Outputs

The project provides the following outputs:

- **S3 Module Outputs**:
    - `s3_bucket_name`: The name of the S3 bucket.
    - `s3_bucket_arn`: The ARN of the S3 bucket.
    - `s3_bucket_domain_name`: The domain name of the S3 bucket.

- **CloudFront Module Outputs**:
    - `cloudfront_distribution_id`: The ID of the CloudFront distribution.
    - `cloudfront_distribution_arn`: The ARN of the CloudFront distribution.
    - `distribution_domain_name`: The domain name of the CloudFront distribution.

## License

This project is licensed under the MIT License.
```
## Authors

- thomasjoseph