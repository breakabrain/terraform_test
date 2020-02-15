# terraform_test
Set variables:
   1. WORKSPACE_NAME in .gitlab-ci.yml file (testing, staging, production);
   2. $NAME_BUCKET in gitlab ci env. variables;
   3. $KEY_FILE in gitlab ci env. variables (name of terraform statefile);
   4. $REGION_BUCKET in gitlab ci env. variables;
   5. AWS_ACCESS_KEY_ID in gitlab ci env. variables;
   6. AWS_SECRET_ACCESS_KEY in gitlab ci env. variables.

Private keys for connection to EC2 instance have \*.ppk extension and are encrypted by ansible vault.
