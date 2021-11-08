#!/bin/sh

set -e

FILE_PATH="${FILE_PATH:-test/__files/fractal.jpg}"

curl localhost:4000/api -X POST \
-F query='mutation ($eventId: ID!, $role: EventAttachmentRole!) { result: uploadEventAttachment(file: "file", eventId: $eventId, role: $role) { success errors eventAttachment { id eventId } } }' \
-F variables="{\"eventId\":1,\"role\":\"MAIN\"}" \
-F file="@$FILE_PATH" \
-H "Authorization: Bearer $TOKEN"
