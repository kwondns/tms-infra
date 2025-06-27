output "instance_public_ip" {
  value = module.be.ec2_public_ip                                          # The actual value to be outputted
  description = "The public IP address of the EC2 instance" # Description of what this output represents
}
