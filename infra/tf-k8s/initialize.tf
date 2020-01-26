# ---------------------------------------------------------------------------------------------------------
# - Empty variable declarations for the variables that will be populated in each env’s .tfvars
# - This file should be shared to all env folders using Symbolic link.
# - Values are populated on env-dev\development.tfvars for example to attribute values specific to the env.
# ---------------------------------------------------------------------------------------------------------

variable "env" {
  description = "Environment name definiton Eg. Dev, Test, QA and Prod"
}
