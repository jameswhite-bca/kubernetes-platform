##############################################################
##############################################################
#######                Standard Variables              #######
##############################################################
#############################################################

variable "app_name" {
  description = "short version of project/application name. Must be lowercase alphanumeric characters and have a maximum length of 14 characters."
  nullable    = false
  sensitive   = false
  type        = string

  validation {
    condition     = length(var.app_name) <= 14 && can(regex("^[a-z0-9]*$", var.app_name))
    error_message = "The app_name must be lowercase alphanumeric characters and have a maximum length of 14 characters."
  }

}
variable "environment" {
  default     = "dev"
  description = "Environment tag e.g. dev, test, systest, UAT, Prod"
  nullable    = false
  sensitive   = false
  type        = string

  validation {
    condition     = can(regex("^(dev|poc|prod|uat|stg|sys)$", var.environment))
    error_message = "Invalid environment tag. Allowed values are dev, uat, stg, sys, poc, and prod."
  }

}

variable "azrm_subscription_id" {
  default     = null
  description = "Azure subscription id - cannot be null if working with azure"
  nullable    = true
  sensitive   = false
  type        = string

  validation {
    condition     = can(regex("^([0-9a-fA-F]){8}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){12}$", var.azrm_subscription_id)) || var.azrm_subscription_id == null
    error_message = "Invalid Azure subscription ID format. It should be a valid GUID."
  }

}

variable "domain_name" {
  description = "Custom domain for the application (for local testing, add to your hosts file)"
  type        = string
  default     = "bookreview.local"
}

variable "letsencrypt_email" {
  description = "Email for Let's Encrypt certificate notifications"
  type        = string
  default     = "dj_ruffnek@hotmail.com"
}

variable "azrm_tenant_id" {
  default     = null
  description = "Azure tenant id. cannot be null if working with Azure"
  nullable    = true
  sensitive   = false
  type        = string

  validation {
    condition     = can(regex("^([0-9a-fA-F]){8}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){12}$", var.azrm_tenant_id)) || var.azrm_tenant_id == null
    error_message = "Invalid Azure tenant ID format. It should be a valid GUID."
  }

}

variable "azrm_resource_location" {
  description = "Resource group location. Must be a valid azure region"
  default     = "northeurope"
  nullable    = false
  sensitive   = false
  type        = string

  validation {
    condition     = can(regex("^(northeurope|uksouth|westeurope)$", var.azrm_resource_location))
    error_message = "Invalid Azure Resource Manager Resource Location. Allowed values are northeurope, uksouth, and westeurope."
  }

}

##############################################################
#######    Book Review Platform Variables             #######
##############################################################

variable "db_name" {
  description = "PostgreSQL database name"
  type        = string
  default     = "bookreviews"
  nullable    = false
}

variable "db_user" {
  description = "PostgreSQL database user"
  type        = string
  default     = "bookuser"
  nullable    = false
}

variable "db_password" {
  description = "PostgreSQL database password"
  type        = string
  sensitive   = true
  nullable    = false
}

variable "jwt_secret" {
  description = "JWT secret key for authentication"
  type        = string
  sensitive   = true
  nullable    = false
}
