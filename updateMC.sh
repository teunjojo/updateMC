#!/bin/bash
version=1.7

lib="libteunjojo"
[ ! -f "$lib.sh" ] && curl -s -o $lib.sh https://files.teunjojo.com/$lib/latest/$lib.sh && chmod +x $lib.sh
source $lib.sh

[ -z "$paperVersion" ] && echo paperVersion="$(curl -sb -H "Accept: application/json" "https://api.papermc.io/v2/projects/paper" | jq .versions[-1] | tr -d \")" >> "$conf"
[ -z "$waterfallVersion" ] && echo waterfallVersion="$(curl -sb -H "Accept: application/json" "https://api.papermc.io/v2/projects/waterfall" | jq .versions[-1] | tr -d \")" >> "$conf"
[ -z "$paperDir" ] && echo paperDir=/opt/minecraft/survival >> "$conf" && editConf=true
[ -z "$waterfallDir" ] && echo waterfallDir=/opt/minecraft/proxy >> "$conf" && editConf=true
[ -z "$updatePaper" ] && echo updatePaper=true >> "$conf"
[ -z "$updateWaterfall" ] && echo updateWaterfall=true >> "$conf" && editConf=true
source "$conf"

[ $editConf ] && echo "Edit '$conf'" && exit

paperBuild="$(curl -s "https://api.papermc.io/v2/projects/paper/versions/$paperVersion" | jq .builds[-1])"
waterfallBuild="$(curl -s "https://api.papermc.io/v2/projects/waterfall/versions/$waterfallVersion" | jq .builds[-1])"

install()
{
project=$1
currentVersion=$2
currentBuild=$3
oldVersion="${project}VersionOld"
oldVersion="${!oldVersion}"
oldBuild="${project}BuildOld"
oldBuild="${!oldBuild}"
[ -z "$oldVersion" ] && oldVersion=unknown
[ -z "$oldBuild" ] && oldBuild=unknown

if ! [[ "$currentVersion-$currentBuild" = "$oldVersion-$oldBuild" ]]; then
  stty igncr
  echo -ne "Updating $project: $oldBuild ($oldVersion) --> $currentBuild ($currentVersion) ... "
  curl -s -o "$project.jar" "https://api.papermc.io/v2/projects/$project/versions/$currentVersion/builds/$currentBuild/downloads/$project-$currentVersion-$currentBuild.jar"
  echo "$versionBuild" > versionBuild
  echo Done
  stty -igncr
  cache "${project}VersionOld" "$currentVersion"
  cache "${project}BuildOld" "$currentBuild"
else
  echo "$project up to date!"
fi
}


[ "$updatePaper" = "true" ] && cd "$paperDir" && install paper "$paperVersion" "$paperBuild"
cd || exit
[ "$updateWaterfall" = "true" ] && cd "$waterfallDir" && install waterfall "$waterfallVersion" "$waterfallBuild"
