# Variables
export SP_NAME="github-oidc-netconf-demo"
export SUB_ID=$(az account show --query id -o tsv)
export TENANT_ID=$(az account show --query tenantId -o tsv)

# 1) Create Azure AD application
az ad app create --display-name $SP_NAME \
  --identifier-uris "api://${SP_NAME}" \
  --query appId -o tsv

# Capture appId
APP_ID=$(az ad app list --display-name $SP_NAME --query "[0].appId" -o tsv)

# 2) Create service principal for the app
az ad sp create --id $APP_ID

# 3) Grant role to the service principal (scope: subscription or resource group)
az role assignment create --assignee $APP_ID --role "Contributor" --scope /subscriptions/$SUB_ID

# 4) Add Federated Identity Credential (so GitHub OIDC can issue tokens)
# Build a federated credential JSON file (federated-credential.json) with something like:
cat > federated-credential.json <<EOF
{
  "name": "github-actions-federated-cred",
  "issuer": "https://token.actions.githubusercontent.com",
  "subject": "repo:YOUR_GITHUB_ORG/YOUR_REPO:ref:refs/heads/main",
  "description": "GitHub Actions OIDC credential for Terraform/Bicep deploy"
}
EOF

# Use Microsoft Graph to add federation (requires 'az rest' / Graph API permission)
az rest --method POST --uri "https://graph.microsoft.com/v1.0/applications/$APP_ID/federatedIdentityCredentials" \
  --headers "Content-Type=application/json" \
  --body @federated-credential.json
