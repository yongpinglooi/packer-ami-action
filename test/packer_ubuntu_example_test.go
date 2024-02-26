package test

import (
	"os"
	"testing"
	"time"

	terratest_aws "github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/packer"
	"github.com/stretchr/testify/assert"
)

// Occasionally, a Packer build may fail due to intermittent issues (e.g., brief network outage or EC2 issue). We try
// to make our tests resilient to that by specifying those known common errors here and telling our builds to retry if
// they hit those errors.
var DefaultRetryablePackerErrors = map[string]string{
	"Script disconnected unexpectedly":                                                 "Occasionally, Packer seems to lose connectivity to AWS, perhaps due to a brief network outage",
	"can not open /var/lib/apt/lists/archive.ubuntu.com_ubuntu_dists_xenial_InRelease": "Occasionally, apt-get fails on ubuntu to update the cache",
}
var DefaultTimeBetweenPackerRetries = 15 * time.Second

const DefaultMaxPackerRetries = 3

// Test without var file
func TestPackerUbuntuExample(t *testing.T) {
	t.Parallel()

	approvedRegions := []string{"us-west-2"}

	// Pick a random AWS region to test in. This helps ensure your code works in all regions.
	awsRegion := terratest_aws.GetRandomStableRegion(t, approvedRegions, nil)

	// Some AWS regions are missing certain instance types, so pick an available type based on the region we picked
	instanceType := terratest_aws.GetRecommendedInstanceType(t, awsRegion, []string{"t2.micro, t3.micro", "t2.small", "t3.small"})

	subnetId := os.Getenv("SUBNET_ID")
	vpcId := os.Getenv("VPC_ID")

	// Read Packer's template and set AWS Region variable.
	packerOptions := &packer.Options{
		// The path to where the Packer template is located
		Template: "../example/",

		// Variables to pass to our Packer build using -var options
		Vars: map[string]string{
			"OS_Name":         "Ubuntu",
			"OS_Version":      "18.04LTS",
			"instance_type":   instanceType,
			"region":          awsRegion,
			"source_ami_name": "ubuntu-bionic-18.04-amd64-server",
			"subnet_id":       subnetId,
			"vpc_id":          vpcId,
		},

		// Only build the AWS AMI
		Only: "amazon-ebs.ubuntu-example",

		// Configure retries for intermittent errors
		RetryableErrors:    DefaultRetryablePackerErrors,
		TimeBetweenRetries: DefaultTimeBetweenPackerRetries,
		MaxRetries:         DefaultMaxPackerRetries,
	}

	// Make sure the Packer build completes successfully
	amiID := packer.BuildArtifact(t, packerOptions)

	// Clean up the AMI after we're done
	defer terratest_aws.DeleteAmiAndAllSnapshots(t, awsRegion, amiID)

	// Check if AMI is private
	amiIsPublic := terratest_aws.GetAmiPubliclyAccessible(t, awsRegion, amiID)
	assert.False(t, amiIsPublic)

}

// Test with var file
func TestPackerUbuntuExampleWithVarFile(t *testing.T) {
	t.Parallel()

	approvedRegions := []string{"us-west-2"}

	// Pick a random AWS region to test in. This helps ensure your code works in all regions.
	awsRegion := terratest_aws.GetRandomStableRegion(t, approvedRegions, nil)

	// Some AWS regions are missing certain instance types, so pick an available type based on the region we picked
	instanceType := terratest_aws.GetRecommendedInstanceType(t, awsRegion, []string{"t2.micro, t3.micro", "t2.small", "t3.small"})

	subnetId := os.Getenv("SUBNET_ID")
	vpcId := os.Getenv("VPC_ID")

	// Read Packer's template and set AWS Region variable.
	packerOptions := &packer.Options{
		// The path to where the Packer template is located
		Template: "../example/",

		// Variables to pass to our Packer build using -var options
		Vars: map[string]string{
			"instance_type": instanceType,
			"name":          "ubuntu-example-2", // name needs to be unique
			"region":        awsRegion,
			"subnet_id":     subnetId,
			"vpc_id":        vpcId,
		},

		// Variables to pass to our Packer build using -var-file options
		VarFiles: []string{
			"../example/ubuntu-18.04.pkrvars.hcl",
		},

		// Only build the AWS AMI
		Only: "amazon-ebs.ubuntu-example",

		// Configure retries for intermittent errors
		RetryableErrors:    DefaultRetryablePackerErrors,
		TimeBetweenRetries: DefaultTimeBetweenPackerRetries,
		MaxRetries:         DefaultMaxPackerRetries,
	}

	// Make sure the Packer build completes successfully
	amiID := packer.BuildArtifact(t, packerOptions)

	// Clean up the AMI after we're done
	defer terratest_aws.DeleteAmiAndAllSnapshots(t, awsRegion, amiID)

	// Check if AMI is private
	amiIsPublic := terratest_aws.GetAmiPubliclyAccessible(t, awsRegion, amiID)
	assert.False(t, amiIsPublic)
}
