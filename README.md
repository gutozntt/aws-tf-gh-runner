# On-Demand GitHub Self-Hosted Runners on AWS

The goal of this project is to have on-demand Github runners on AWS to run your jobs. In this project, each workflow run will have its own runner on AWS. However, if the desire is to have one or more runners running all the time you can still benefit from the terraform code provided in `aws-tf-gh-runner/` folder.

## Context (My Use Case)

In another projects, I was using GitHub Actions to build amd64 docker images and was satisfied with the performance and build time. There was a realization for the need to have more Network Bandwidth for the AWS ECS EC2 Hosts. After reviewing the available instance types that AWS provides in this region, the best price-performance instance type that was found was a c6gn.large. Amazon EC2 c6gn instances are powered by ARM-based AWS Graviton2 processors, and they offer generally a high network bandwith. To run the application in c6gn, there would be a need to rebuild the docker image in arm64 architecture instead of amd64 like was initially happening.

## The Challenge

Currently GitHub does not provide arm64 runners and also does not support docker in their MacOS runners, the first solution found was to build arm64 images through the amd64 GitHub runners using QEMU and BUILDX.

```
        - name: Set up QEMU
          uses: docker/setup-qemu-action@v2

        - name: Set up Docker Buildx
          id: buildx
          uses: docker/setup-buildx-action@v2
            
        - name: Build
          run: |
            docker buildx build --platform=linux/arm64  .
```

The above method worked, however, the base image that usually took 5 minutes to build in amd64 started to take 55 minutes and the application image (on top of my base image) that usually took 2 minutes started to take 6 minutes. Waiting 55 minutes to build the base image was really out of scope and would slow down the CI/CD process. 

## The Solution

The solution for the above challenges inspired creation of this automation project where there will have on-demand self-hosted runners on AWS to run the project jobs. This use case is more related to docker builds but it really can be used for anything. In addition to that, runners can be configured with whatever specifications with the project pipeline yaml files. Keep reading for instructions and documentation.

# Get Started

The first thing you need to do is connect your repo to your AWS Account. To do that, you need an AWS_ACCESS_KEY_ID and an AWS_SECRET_ACCESS_KEY. I recommend you create an user with Administrator privileges so we can run Terraform through it. Once you have the pair of keys, you need to create two repository secrets in Github Actions called exactly:

- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY

Once you have done that, you need to create the following two SSM Parameters in your AWS Account:

- github-pat - This parameter will have on its value your Github Personal Access Token.

- github-runner-context - This parameter will have on its value the Github Repository URL where you will register your runners.

Note: Make sure you create the SSM Parameters in the same region where you are willing to create your runners.

## Configuring your Runners

Now that we have our Github repository connected to our AWS Account and the SSM Parameters in place, we need to configure our Runners' specifications. All the settings are done through our workflow yaml file that you can find in .github/workflows/build.yaml. You will set the following options: 

Mandatory:
```
  TF_VAR_instance_type: t4g.nano
  TF_VAR_subnet_id: subnet-0e3e862a4e38ec0e1
  TF_VAR_vpc_security_group_ids: '["sg-07108abbdfbb0a56d"]'
  TF_VAR_region: us-east-1
  TF_VAR_runner_architecture: ARM64
```

Optional:
```
  TF_VAR_runner_name:
  TF_VAR_ami:
  TF_VAR_key_name:
  TF_VAR_monitoring: 
  TF_VAR_iam_instance_profile:
```

The environment will automatically fetch the latest Amazon Linux 2 AMI based on the architecture that you choose. However, if you want to have a custom AMI with pre-installed tools, you just need to set the TF_VAR_ami. Make sure you use an Amazon Linux 2 image. 

These variables set in the workflow yaml will be passed to the following Terraform variables:

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami"></a> [ami](#input\_ami) | AMI ID for your Runners. Must be Amazon Linux 2. | `string` | `null` | no |
| <a name="input_iam_instance_profile"></a> [iam\_instance\_profile](#input\_iam\_instance\_profile) | IAM Role for your Runners. | `string` | `null` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | EC2 Instance Type for your Runners. | `string` | n/a | yes |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | EC2 Key Pair Name for your Runners. | `string` | `null` | no |
| <a name="input_label"></a> [label](#input\_label) | Github Labels for your Runners. | `string` | n/a | yes |
| <a name="input_monitoring"></a> [monitoring](#input\_monitoring) | Whether to enable monitoring for your Runners. | `bool` | `false` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region for your Runners. | `string` | n/a | yes |
| <a name="input_runner_architecture"></a> [runner\_architecture](#input\_runner\_architecture) | Architecture for your Runners. It should be one of the following: x64, ARM or ARM64 | `string` | n/a | yes |
| <a name="input_runner_name"></a> [runner\_name](#input\_runner\_name) | Name for your Runners. | `string` | `"github-runner"` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnet ID for your Runners. | `string` | n/a | yes |
| <a name="input_vpc_security_group_ids"></a> [vpc\_security\_group\_ids](#input\_vpc\_security\_group\_ids) | List of Security Groups for your Runners. | `list(any)` | n/a | yes |

## Running the Pipeline

The pipeline is currently configured to automatically trigger for any new push to the main branch.

## Customize build steps

For any custom build step or job that you want to add, you should place between the jobs "start_runner" and "stop_runner". You can use the job "build" as an example. The most important thing is to add the following line in your jobs:

```runs-on: [self-hosted, "${{needs.start_runner.outputs.github_run_number}}"]```

## Important notes

- Make sure you choose a right instance type based on the architecture you choose. Like t4g with ARM64 and t3 with x64.
- This project uses Terraform to provision and deprovision the runners. The state files are local and handled as Artifacts in each workflow run.

## Other Use Cases

You don't need to use this automation project just if you need to build arm64 docker images faster. There are some other use cases where you will need to have self-hosted runners, for example: To run jobs that needs communication with private resources within your infrastructure such as database connections or you need to follow some compliance that does not allow to build your internal applications through external resources.

# Conclusion

Github Actions is a powerful tool to create CI/CD pipelines and make it easy to automate all your software workflows. On the other hand, AWS is a powerful cloud provider with a great set of services available to deploy any kind of application into the cloud. In this project we are integrating these two powerful services which gives us the ability to use On-Demand self-hosted Runners with different architectures, improving our build performance, being able to customize our runners, following security compliances and since you will not have runners running all the time, you will also be optimizing your costs.

