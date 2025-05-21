resource "azurerm_resource_group" "sds_platform_resource_group" {
  name     = format("%s-%s-test-rg", var.product, var.env)
  location = "Uk South"
  tags = module.common_tags.common_tags
}

module "key_vault" {
  source              = "git@github.com:hmcts/cnp-module-key-vault?ref=master"
  name                = "sds-platform-sbox-test2" // Max 24 characters
  product             = var.product
  env                 = var.env
  object_id           = var.jenkins_AAD_objectId
  resource_group_name = azurerm_resource_group.sds_platform_resource_group.name
  product_group_name  = "DTS Platform Operations"
  common_tags         = module.common_tags.common_tags
}

resource "azurerm_key_vault_secret" "POSTGRES-USER" {
  name         = "sds-platform-testing-POSTGRES-USER"
  value        = module.postgresql.username
  key_vault_id = module.key_vault.key_vault_id
  
  depends_on = [
    module.key_vault,
    module.postgresql
  ]
}

resource "azurerm_key_vault_secret" "POSTGRES-PASS" {
  name         = "sds-platform-testing-POSTGRES-PASS"
  value        = module.postgresql.password
  key_vault_id = module.key_vault.key_vault_id

  depends_on = [
    module.key_vault,
    module.postgresql
  ]
}

module "postgresql" {
  
  providers = {
    azurerm.postgres_network = azurerm.postgres_network
  }

  source = "git@github.com:hmcts/terraform-module-postgresql-flexible?ref=postgres-db-report-perms"
  env    = var.env

  product       = var.product
  component     = "testing"
  business_area = "sds" # sds or cft

  resource_group_name = azurerm_resource_group.sds_platform_resource_group.name

  # The original subnet is full, this is required to use the new subnet for new databases
  subnet_suffix = "expanded"

  pgsql_databases = [
    {
      name : "application"
      report_privilege_schema : "public"
      report_privilege_tables : ["nutmeg", "ginger"]
    },
    {
      name : "application2"
      report_privilege_schema : ""
      report_privilege_tables : ["springOnion"]
    }
  ]

  pgsql_sku     = "GP_Standard_D2ds_v4"
  pgsql_version = "16"

  # Changing the value of the trigger_password_reset variable will trigger Terraform to rotate the password of the pgadmin user.
  trigger_password_reset = "1"
  
  enable_read_only_group_access = false
  enable_db_report_privileges = false
  force_db_report_privileges_trigger = "1"
  
  kv_name = "sds-platform-sbox-test2"
  kv_subscription = "DTS-SHAREDSERVICES-SBOX"

  common_tags = module.common_tags.common_tags

  depends_on = [
    module.key_vault,
    module.common_tags
  ]
}

module "common_tags" {
  source      = "git@github.com:hmcts/terraform-module-common-tags.git?ref=master"
  environment = "sandbox"
  product     = "sds-platform"
  builtFrom   = "Manual"
  expiresAfter = "2025-05-30"
}