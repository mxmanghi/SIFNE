function homedir=gethome()

    if ispc; homedir= getenv('USERPROFILE');
    else; homedir= getenv('HOME');
    end
end
