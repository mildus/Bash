#!/bin/bash
#author imanyakov

#output coloring
red=$(tput setaf 1)
green=$(tput setaf 2)
coff=$(tput sgr0)
test_result="${green}TEST PASS${coff}\n"

#variables
file1="/usr/share/firefox/browser/defaults/preferences/firefox.js"
params="
lockPref\(\"extensions.blocklist.enabled\"\,\sfalse
lockPref\(\"network.prefetch-next\"\,\sfalse
lockPref\(\"network.http.speculative-parallel-limit\"\,\s0
pref\(\"browser.startup.homepage\"\,\s+\"https:\/\/astralinux.ru\"
lockPref\(\"browser.newtabpage.activity-stream.feeds.telemetry\"\,\sfalse
lockPref\(\"browser.newtabpage.activity-stream.telemetry\"\,\sfalse
lockPref\(\"browser.ping-centre.telemetry\"\,\sfalse
lockPref\(\"toolkit.telemetry.archive.enabled\"\,\sfalse
lockPref\(\"toolkit.telemetry.bhrPing.enabled\"\,\sfalse
lockPref\(\"toolkit.telemetry.enabled\"\,\sfalse
lockPref\(\"toolkit.telemetry.firstShutdownPing.enabled\"\,\sfalse
lockPref\(\"toolkit.telemetry.newProfilePing.enabled\"\,\sfalse
lockPref\(\"toolkit.telemetry.reportingpolicy.firstRun\"\,\sfalse
lockPref\(\"toolkit.telemetry.server\"\,\sfalse
lockPref\(\"toolkit.telemetry.shutdownPingSender.enabled\"\,\sfalse
lockPref\(\"toolkit.telemetry.unified\"\,\sfalse
lockPref\(\"toolkit.telemetry.updatePing.enabled\"\,\sfalse
lockPref\(\"browser.safebrowsing.downloads.remote.enabled\"\,\sfalse
pref\(\"security.OCSP.enabled\"\,\s0
lockPref\(\"toolkit.telemetry.hybridContent.enabled\",\sfalse
lockPref\(\"devtools.onboarding.telemetry.logged\",\sfalse
lockPref\(\"app.update.auto\",\sfalse
lockPref\(\"extensions.update.enabled\",\sfalse
lockPref\(\"extensions.update.url\",\s\"\s\"
lockPref\(\"extensions.update.background.url\",\s\"\s\"
lockPref\(\"extensions.update.interval\",\s0
lockPref\(\"app.update.timerMinimumDelay\",\s0
lockPref\(\"app.update.checkInstallTime\",\sfalse
lockPref\(\"services.sync.prefs.sync.browser.search.update\",\sfalse
lockPref\(\"services.sync.prefs.sync.extensions.update.enabled\",\sfalse
lockPref\(\"browser.search.update\",\sfalse
lockPref\(\"app.update.url\",\s\"\s\"
"
 #main
for param in $params; do
        grep -E $param $file1 #&> /dev/null
    if [[ $? == 0 ]]; then
        printf "${green}OK${coff}\n"
    else
        printf "${red}FAIL${coff}\n"
        test_result="${red}TEST FAIL!${coff}\n"
    fi
done
printf "$test_result"