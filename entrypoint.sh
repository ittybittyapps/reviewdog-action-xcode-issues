#!/bin/sh

cd "$GITHUB_WORKSPACE" || exit

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

xcissues "${INPUT_XCRESULT_JSON_FILE}" | reviewdog \
    -f="rdjson" \
    -name="Xcode" \
    -reporter="${INPUT_REPORTER:-github-pr-check}" \
    -level="${INPUT_LEVEL:-error}" \
    -filter-mode="${INPUT_FILTER_MODE:-added}" \
    -fail-on-error="${INPUT_FAIL_ON_ERROR:-false}" \
    ${INPUT_REVIEWDOG_FLAGS}