# ───✧ function: install APKs via adb ───✧
function apk --description "📱 Install all APKs in the current folder via adb and move to /home/ls/0/backup/apks"
    set backup_dir "/home/ls/0/backup/apks"
    if not test -d "$backup_dir"
        mkdir -p "$backup_dir"
    end

    set apks (ls *.apk 2>/dev/null)
    if test (count $apks) -eq 0
        echo "🚫 No APKs found in the current directory."
        return 1
    end

    set installed_apks
    for f in $apks
        echo "📦 Installing $f..."
        adb install "$f"
        if test $status -eq 0
            echo "✅ Installed! Moving $f to $backup_dir"
            mv "$f" "$backup_dir"
            set installed_apks $installed_apks $f
        else
            echo "❌ Failed to install $f"
        end
    end

    echo "🎉 Process completed."
    if command -q notify-send
        if test (count $installed_apks) -gt 0
            set msg (string join "\n" $installed_apks)
            notify-send "📱 Installed APKs" "$msg"
        else
            notify-send "APK Installation" "No APKs were installed."
        end
    end
end
