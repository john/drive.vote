#!/bin/bash

set -e

# First parameter should be "development" or "production"
# [optional] Second parameter is the aws region.

MODE="${1}"; shift

if [ "$MODE" != "production" ] && [ "$MODE" != "development" ]; then
  echo "First argument must be production or development."
  exit 1
fi

if [ -n "${1}" ]; then
  export AWS_DEFAULT_REGION="${1}"
  shift
fi

#####################
#### Done with parameter parsing.

if [ "${MODE}" = "production" ]; then
  EB_ENVNAME='drivevote-prod'

  # Allow alternate env var overrides in CI.
  if [ -n "$CI" ]; then
    if [ -n "${PROD_AWS_ACCESS_KEY_ID}" ]; then
      export AWS_ACCESS_KEY_ID="${PROD_AWS_ACCESS_KEY_ID}"
    fi
    if [ -n "${PROD_AWS_SECRET_ACCESS_KEY}" ]; then
      export AWS_SECRET_ACCESS_KEY="${PROD_AWS_SECRET_ACCESS_KEY}"
    fi
  fi
else
  EB_ENVNAME='drivevote-dev'

  # Allow alternate env var overrides in CI.
  if [ -n "$CI" ]; then
    if [ -n "${DEV_AWS_ACCESS_KEY_ID}" ]; then
      export AWS_ACCESS_KEY_ID="${DEV_AWS_ACCESS_KEY_ID}"
    fi
    if [ -n "${DEV_AWS_SECRET_ACCESS_KEY}" ]; then
      export AWS_SECRET_ACCESS_KEY="${DEV_AWS_SECRET_ACCESS_KEY}"
    fi
  fi
fi

# Precompile all assets first so if there are errors, this task bails early.
# This generates files in public/assets and public/webpack.
rm -rf public/webpack
export NODE_ENV='production'  # Always build webpack in production mode.
rake assets:precompile

# Snapshot the source code from HEAD into the deploy artifact.
# This will NOT contain the precompiled assets.
ARTIFACT_FILE='tmp/deploy_artifact.zip'
git archive -o "${ARTIFACT_FILE}" HEAD

# Add in the precompiled assets to the deploy file.
zip -ru "${ARTIFACT_FILE}" public/assets
zip -ru "${ARTIFACT_FILE}" public/webpack

eb deploy "${EB_ENVNAME}"
