#!/bin/sh

set -e

FILE_PATH="${FILE_PATH:-test/__files/lorem-ipsum.pdf}"

curl localhost:4000/api -X POST \
-F query='mutation ($eventId: ID!, $role: EventAttachmentRole!) { result: uploadEventAttachment(file: "file", eventId: $eventId, role: $role) { success errors eventAttachment { id eventId } } }' \
-F variables="{\"eventId\":1,\"role\":\"ATTACHMENT\"}" \
-F file="@$FILE_PATH" \
-H "Authorization: Bearer $TOKEN"
