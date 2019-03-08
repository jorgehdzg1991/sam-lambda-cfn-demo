echo ":::: Staging deployment starting"




#########################################
# ::::::::::::::: Setup :::::::::::::::::
#########################################

# exit when any command fails
set -e

# local variables
CURRENT_DATE=$(date '+%Y%m%d%H%M%S')
PROJECT_NAME="lambda-cfn-demo"
ENV="dev"
BUCKET_NAME="deployment-files-bucket"
S3_SUBFOLDER="deployments/$ENV/$CURRENT_DATE"




#########################################
# ::::::::::::: PreDeploy :::::::::::::::
#########################################

echo ":::: Executing lint"
yarn lint

echo ":::: Executing unit tests"
yarn test




#########################################
# ::::::::::::::: Build :::::::::::::::::
#########################################

echo ":::: Compiling stack templates"
cfn-include ./cloudformation/stacks/deploy-lambda-role.yml -y > ./cloudformation/compiled/deploy-lambda-role.yml
cfn-include ./cloudformation/stacks/deploy-lambda.yml -y > ./cloudformation/compiled/deploy-lambda.yml

echo ":::: Packaging stacks"
sam package \
    --template-file ./cloudformation/compiled/deploy-lambda-role.yml \
    --s3-bucket ${BUCKET_NAME} \
    --output-template-file cloudformation/packaged/deploy-lambda-role.yml
sam package \
    --template-file ./cloudformation/compiled/deploy-lambda.yml \
    --s3-bucket ${BUCKET_NAME} \
    --output-template-file cloudformation/packaged/deploy-lambda.yml

echo ":::: Uploading compiled stacks"
aws s3 sync \
    cloudformation/packaged/ "s3://$BUCKET_NAME/$S3_SUBFOLDER/compiled_templates" \
    --exclude "*" \
    --include "*.yml"




#########################################
# :::::::::::::: Deploy :::::::::::::::::
#########################################

echo ":::: Starting deployment"
sam deploy \
    --template-file cloudformation/deploy-master.yml \
    --stack-name ${PROJECT_NAME} \
    --capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND \
    --parameter-overrides \
        ProjectName=${PROJECT_NAME} \
        Env=${ENV} \
        DeployFilesBucket=${BUCKET_NAME} \
        ArtifactsPath="$S3_SUBFOLDER/compiled_templates" \
    --s3-bucket ${BUCKET_NAME} \
    --s3-prefix $S3_SUBFOLDER
