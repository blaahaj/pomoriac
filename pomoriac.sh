#!/bin/bash

set -eu

# Available executables
find $( echo "$PATH" | tr : ' ' ) -maxdepth 1 -mindepth 1 -type f -perm -0001 -print | sort

[ -f "$POMORIAC_MANIFEST" ]

owner=$( jq -r .owner < "$POMORIAC_MANIFEST" )

gh api graphql --paginate -F 'query=
  query($owner: String!, $endCursor: String) {
    organization(login: $owner) {
      id
      login
      repositories(first: 30, after: $endCursor) {
        pageInfo { endCursor hasNextPage }
        nodes {
          id
          name
          isArchived
          visibility
          repositoryTopics(first: 20) {
            nodes { id topic { name } }
            totalCount
            pageInfo { hasNextPage }
          }
        }
      }
    }
  }
' -F owner="$owner" | jq --slurp . > got.json

cat got.json
