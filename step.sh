#!/bin/bash
set -ex

echo "This is the value specified for the input 'repository_url': ${repository_url}"

#
# --- Export Environment Variables for other Steps:
# You can export Environment Variables for other Steps with
#  envman, which is automatically installed by `bitrise setup`.
# A very simple example:
# envman add --key EXAMPLE_STEP_OUTPUT --value 'the value you want to share'
# Envman can handle piped inputs, which is useful if the text you want to
# share is complex and you don't want to deal with proper bash escaping:
#  cat file_with_complex_input | envman add --KEY EXAMPLE_STEP_OUTPUT
# You can find more usage examples on envman's GitHub page
#  at: https://github.com/bitrise-io/envman

#
# --- Exit codes:
# The exit code of your Step is very important. If you return
#  with a 0 exit code `bitrise` will register your Step as "successful".
# Any non zero exit code will be registered as "failed" by `bitrise`.


# git@github.com:alphaversion/bamboo.git -> https://api.github.com/repos/:owner/:repo/issues/:issue_number

if [ -z "${issue_number}" ]; then
    issue_number=`echo "${GIT_CLONE_COMMIT_MESSAGE_SUBJECT}" | sed -E "s/^.*#([0-9]+).*$/\1/"`
fi

OWNER=`echo ${repository_url} | sed -E "s/git@github.com\:(.*)\/(.*)\.git/\1/"`
REPOSITORY=`echo ${repository_url} | sed -E "s/git@github.com\:(.*)\/(.*)\.git/\2/"`

URL="https://api.github.com/repos/$OWNER/$REPOSITORY/issues/${issue_number}"

RESULT=`curl "$URL" -H "Authorization: token ${personal_access_token}"`

TITLE=`echo $RESULT | jq '.title' | sed -E "s/\r//g" | sed -E "s/^\"//g" | sed -E "s/\"$//g"`
BODY=`echo $RESULT | jq '.body' | sed -E "s/\r//g" | sed -E "s/^\"//g" | sed -E "s/\"$//g"`

envman add --key GITHUB_ISSUE_TITLE --value $TITLE
envman add --key GITHUB_ISSUE_BODY --value $BODY
