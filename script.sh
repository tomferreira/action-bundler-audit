#!/bin/sh
set -e

if [ -n "${GITHUB_WORKSPACE}" ]; then
  cd "${GITHUB_WORKSPACE}/${INPUT_WORKDIR}" || exit
fi

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

echo '::group:: Installing bundler-audit with extensions ... https://github.com/rubysec/bundler-audit'
# if 'gemfile' bundler-audit version selected
if [ "$INPUT_BUNDLER_AUDIT_VERSION" = "gemfile" ]; then
  # if Gemfile.lock is here
  if [ -f 'Gemfile.lock' ]; then
    # grep for bundler-audit version
    BUNDLER_AUDIT_GEMFILE_VERSION=$(ruby -ne 'print $& if /^\s{4}bundler-audit\s\(\K.*(?=\))/' Gemfile.lock)

    # if bundler-audit version found, then pass it to the gem install
    # left it empty otherwise, so no version will be passed
    if [ -n "$BUNDLER_AUDIT_GEMFILE_VERSION" ]; then
      BUNDLER_AUDIT_VERSION=$BUNDLER_AUDIT_GEMFILE_VERSION
      else
        printf "Cannot get the bundler-audit's version from Gemfile.lock. The latest version will be installed."
    fi
    else
      printf 'Gemfile.lock not found. The latest version will be installed.'
  fi
  else
    # set desired bundler-audit version
    BUNDLER_AUDIT_VERSION=$INPUT_BUNDLER_AUDIT_VERSION
fi

gem install -N bundler-audit --version "${BUNDLER_AUDIT_VERSION}"
echo '::endgroup::'

echo '::group:: Running bundler-audit with reviewdog 🐶 ...'
bundler-audit update

bundler-audit check --format json ${INPUT_BUNDLER_AUDIT_FLAGS} | 
  ruby tordjson.rb |
  reviewdog -f=rdjson \
    -name="${INPUT_TOOL_NAME}" \
    -reporter="${INPUT_REPORTER}" \
    -filter-mode="${INPUT_FILTER_MODE}" \
    -fail-on-error="${INPUT_FAIL_ON_ERROR}" \
    -level="${INPUT_LEVEL}" \
    ${INPUT_REVIEWDOG_FLAGS}

exit_code=$?
echo '::endgroup::'

exit $exit_code