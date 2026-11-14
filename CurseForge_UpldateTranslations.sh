#!/bin/bash

if [ -f ".env" ]; then
	. ".env"
fi

declare -A translationStrings
translationTempFile=$(mktemp)
regex='L\[\"([^]]+)\"\]'

process_addon_translations(){
while read -r line || [ -n "$line" ] ; do
	if [[ $line =~ $regex ]] ; then
		translationStrings["${BASH_REMATCH[1]}"]=true
	fi
done < <(cat "$1" | grep -oP $regex);
}

while IFS= read -r -d '' line; do
	process_addon_translations "$line"
done < <(find . -type f -name "*.lua" -not -path "*/Locales/*" -not -path "*/Libs/*" -not -path "*/.release/*" -print0)

for x in "${!translationStrings[@]}"; do
	printf "L[\"%s\"] = %s\n" "$x" "${translationStrings[$x]}" >> "$translationTempFile"
done

if [ ! -s $translationTempFile ]; then
  echo "No localization strings found; nothing to upload."
  exit 0
fi

shopt -s nullglob
tocFiles=(./*.toc)
shopt -u nullglob

if [ "${#tocFiles[@]}" -ne 1 ]; then
  echo "Error: Expected exactly one .toc file in the addon root." >&2
  exit 1
fi

if ! projectID=$(sed -n 's/^[[:space:]]*##[[:space:]]*X-Curse-Project-ID:[[:space:]]*\([0-9][0-9]*\)[[:space:]]*$/\1/p' "${tocFiles[0]}") ||
   [[ ! "$projectID" =~ ^[0-9]+$ ]] || [[ "$projectID" =~ ^0+$ ]]; then
  echo "Error: ${tocFiles[0]} must contain one valid X-Curse-Project-ID." >&2
  exit 1
fi

#language: "enUS", //[enUS, deDE, esES, ect], Required, No Default
#       namespace: "toc", //Any namespace name, comma delimited. Default: Base Namespace
#       formatType: TableAdditions, //['GlobalStrings','TableAdditions','SimpleTable']. Default: TableAdditions
#       missing-phrase-handling: DoNothing //['DoNothing', 'DeleteIfNoTranslations', 'DeleteIfTranslationsOnlyExistForSelectedLanguage', 'DeletePhrase']. Default: DoNothing
#   localizations: "Localizations To Import"

result=$( curl -sS -0 -o /dev/null -X POST -w "%{http_code}" \
-H "X-Api-Token: $CF_API_KEY" \
-F "metadata={ language: \"enUS\", formatType: \"TableAdditions\", \"missing-phrase-handling\": \"DeletePhrase\" }" \
-F "localizations=<$translationTempFile" \
"https://legacy.curseforge.com/api/projects/$projectID/localization/import"
) || exit 1

case $result in
200)
  echo "Exported localisation string to curse forge."
  exit 0
  ;;
*)
  echo -e "Error exporting localisation to curse forge. Response:\n $result \n"
  exit 1
  ;;
esac

