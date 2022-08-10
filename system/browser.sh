#!/bin/sh

# My personal browser configuration
librewolf_dir=$HOME/.librewolf
firefox_dir=$HOME/.mozilla/firefox

if [ -e $librewolf_dir ] && [ -e $firefox_dir ]
then
    librewolf_extensions_dir=$librewolf_dir/$(ls $HOME/.librewolf | grep -E *-release)/extensions
    firefox_extensions_dir=$firefox_dir/$(ls $HOME/.mozilla/firefox | grep -E *-release)/extensions
    links="https://addons.mozilla.org/firefox/downloads/file/3961087/ublock_origin-1.43.0.xpi\
           https://addons.mozilla.org/firefox/downloads/file/3965972/vimium_c-1.98.3.xpi\
           https://addons.mozilla.org/firefox/downloads/file/3910598/canvasblocker-1.8.xpi\
           https://addons.mozilla.org/firefox/downloads/file/3902154/decentraleyes-2.0.17.xpi\
           https://addons.mozilla.org/firefox/downloads/file/3971429/cookie_autodelete-3.8.1.xpi\
           https://addons.mozilla.org/firefox/downloads/file/3965730/i_dont_care_about_cookies-3.4.1.xpi\
           https://addons.mozilla.org/firefox/downloads/file/3872283/privacy_badger17-2021.11.23.1.xpi\
           https://addons.mozilla.org/firefox/downloads/file/3968598/duckduckgo_for_firefox-2022.6.27.xpi\
           https://addons.mozilla.org/firefox/downloads/file/3954910/noscript-11.4.6.xpi\
           https://addons.mozilla.org/firefox/downloads/file/3790944/dont_track_me_google1-4.26.xpi\
           https://addons.mozilla.org/firefox/downloads/file/3980848/clearurls-1.25.0.xpi"

    mkdir -p $librewolf_extensions_dir $firefox_extensions_dir

    for link in $links
    do
        dir=$(mktemp -d)
        file=$(echo $link | awk 'BEGIN{FS="/"} {print $NF}')

        echo -n "Installing $file..."
        cd $dir
        wget -q $link
        unzip -q ./$file -d $dir

        if [ -e $dir/mozilla-recommendation.json ]
        then
            addon_id=$(egrep -o 'addon_id":"[^"]+' ./mozilla-recommendation.json | awk 'BEGIN{FS="\""} {print $NF}')
        else
            addon_id=$(egrep -o 'id":[\ ]+"[^"]+' ./manifest.json | awk 'BEGIN{FS="\""} {print $NF}')
        fi
        if [ "$addon_id" != "" ]
        then
            cp $dir/$file $librewolf_extensions_dir/${addon_id}.xpi
            # cp $dir/$file $firefox_extensions_dir/${addon_id}.xpi
            echo "done"
        else
            echo "error"
        fi
    done

    echo "defaultPref("browser.sessionstore.resume_from_crash", false);
defaultPref("network.cookie.lifetimePolicy", 0);
defaultPref("privacy.resistFingerprinting", false);
defaultPref("privacy.clearOnShutdown.cookies", false);" > $librewolf_dir/librewolf.overrides.cfg
fi

