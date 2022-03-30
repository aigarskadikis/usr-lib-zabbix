#!/bin/bash
find '/root/zabbix-source/templates/san' -type f -name '*.yaml' | \
while IFS= read -r TEMPLATE
do {
echo $TEMPLATE
grep "      template: '" "$TEMPLATE"
curl -sk -X POST \
	-H "Content-Type: application/json" \
	-d "$(php import_template.php \
	876748b4d4ecf5d4d62443c4d5769a699550bdca4be22ab2c1680fe1f65cd53f \
	"$TEMPLATE")" \
	http://158.101.218.248:160/api_jsonrpc.php
echo -e "\n"
} done
