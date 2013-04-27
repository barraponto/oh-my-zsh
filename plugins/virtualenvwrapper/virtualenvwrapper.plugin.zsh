wrapsource=`which virtualenvwrapper_lazy.sh`

if [[ -f "$wrapsource" ]]; then
  source $wrapsource

  if [[ ! $DISABLE_VENV_CD -eq 1 ]]; then
    # Automatically activate Git projects' virtual environments based on the
    # directory name of the project. Virtual environment name can be overridden
    # by placing a .venv file in the project root with a virtualenv name in it
    function _workon_cwd {
        # Check that this is a Git repo
        local repo_root=`git_get_root`
        if [[ -n "$repo_root" ]]; then
            # Check for virtualenv name override
            local env_name=`basename "$repo_root"`
            if [[ -f "$repo_root/.venv" ]]; then
                env_name=`cat "$repo_root/.venv"`
            fi
            # Activate the environment only if it is not already active
            if [[ "$VIRTUAL_ENV" != "$WORKON_HOME/$env_name" ]]; then
                if [[ -e "$WORKON_HOME/$env_name/bin/activate" ]]; then
                    workon "$env_name" && export CD_VIRTUAL_ENV="$env_name"
                else
                  _deactivate
                fi
            fi
          else
            # We've just left the repo, deactivate the environment
            # Note: this only happens if the virtualenv was activated automatically
            _deactivate
        fi
    }

    function _deactivate() {
      if [[ -n $CD_VIRTUAL_ENV ]]; then
        deactivate && unset CD_VIRTUAL_ENV
      fi
    }

    # New cd function that does the virtualenv magic
    function cd {
        builtin cd "$@" && _workon_cwd
    }
  fi
else
  print "zsh virtualenvwrapper plugin: Cannot find virtualenvwrapper_lazy.sh. Please install with \`pip install virtualenvwrapper\`."
fi
