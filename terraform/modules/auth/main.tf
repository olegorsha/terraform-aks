data "azuread_domains" "aad_domains" {
  only_initial = true
}

data "azurerm_kubernetes_cluster" "example" {
  name                = "${var.name}-aks"
  resource_group_name = "${var.name}-rg"
}

provider "kubernetes" {
  config_path = "./config"
#  host                   = "https://localhost:4443" #data.azurerm_kubernetes_cluster.example.kube_config[0].host
#  client_certificate     = base64decode(data.azurerm_kubernetes_cluster.example.kube_config.0.client_certificate)
#  client_key             = base64decode(data.azurerm_kubernetes_cluster.example.kube_config.0.client_key)
#  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.example.kube_config.0.cluster_ca_certificate)
}

locals {
  domain_name = data.azuread_domains.aad_domains.domains.0.domain_name
}

# Azure AD Group
resource "azuread_group" "devops" {
  display_name     = "aks-devops"
  security_enabled = true
}

# Azure AD User
resource "azuread_user" "devops" {
  user_principal_name = format("%s@%s", "aks-devops-user", local.domain_name)
  display_name        = "aks-devops-user"
  password            = "Qwe134Asd1!"
}

# Azure AD Group Member assignment
resource "azuread_group_member" "devops" {
  group_object_id  = azuread_group.devops.id
  member_object_id = azuread_user.devops.id
}

resource "kubernetes_role" "devops-role" {
  metadata {
    name = "devops-full-access-role"
    namespace = kubernetes_namespace.devops.id
  }

  rule {
    api_groups = [""]
    resources  = ["pods", "pods/exec", "pods/portforward", "secrets", "services", "replicationcontrollers"]
    verbs      = ["create", "delete", "deletecollection", "get", "list", "patch", "update", "watch", "logs"]
  }

  rule {
    api_groups = ["apps"]
    resources  = ["deployments", "statefulsets", "daemonsets", "replicasets" ]
    verbs      = ["create", "get", "list", "watch"]
  }

  rule {
    api_groups = ["networking.k8s.io"]
    resources  = ["ingresses"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["extensions"]
    resources  = ["deployments"]
    verbs      = ["create", "get", "list", "watch"]
  }

  rule {
    api_groups = ["batch"]
    resources  = ["jobs", "cronjobs"]
    verbs      = ["*"]
  }
}

resource "kubernetes_namespace" "devops" {
  metadata {
    annotations = {
      name = "devops-annotation"
    }

    labels = {
      label = "devops-namespace-value"
    }

    name = "devops"
  }
}

resource "kubernetes_role_binding" "example" {
  metadata {
    name      = "${kubernetes_namespace.devops.metadata.0.name}-${azuread_group.devops.id}-rolebinding"
    namespace = kubernetes_namespace.devops.metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.devops-role.metadata[0].name
  }

  subject {
    kind      = "Group"
    namespace = kubernetes_namespace.devops.id
    name      = azuread_group.devops.id
    api_group = ""
  }
}
