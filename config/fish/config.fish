# ───✧ interactive check ───✧
if status is-interactive
    # Commands to run in interactive sessions can go here
end

# ───✧ aliases ───✧
alias ativar='source ~/0/venv/bin/activate.fish'
alias bots='cd ~/0/bots'
set -Ux ZED_ALLOW_ROOT true

# ───✧ functions ───✧
function p1
    if test -d venv -o -d .venv
        if test -d venv
            source venv/bin/activate.fish
        else if test -d .venv
            source .venv/bin/activate.fish
        end
    else
        eval "ativar"
    end

    if test -f main.py
        command python main.py
    else if test -f bot.py
        command python bot.py
    else
        echo "No 'main.py' or 'bot.py' found."
    end
end

function python
    if test "$argv[1]" = "main.py" -o "$argv[1]" = "bot.py"
        p1
    else
        command python $argv
    end
end

# ───✧ environment variables ───✧
set -x XDG_DATA_DIRS /run/current-system/sw/share:$XDG_DATA_DIRS
