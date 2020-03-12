#!/bin/sh

WEB_FOLDER='/cd-slides'
export RESOURCE_FOLDER='/resources'
export INPUT_INDEX_HTML_TEMPLATE="${WEB_FOLDER}/index.html"
export OUTPUT_INDEX_HTML="${WEB_FOLDER}/index.html"

echo "Templating index.html"
/scripts/templateIndexHtml

echo "Starting reveal.js development mode"
exec npm run start --prefix "${WEB_FOLDER}"