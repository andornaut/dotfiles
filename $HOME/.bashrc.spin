[[ -n ${SPIN} ]] || return 

export GOG_DEFAULT_REPOSITORY_NAME=dotfiles
export GOG_HOME=${HOME}

# https://github.com/Shopify/web/tree/master/spinx#sourcemaps
export SPINX_ENABLE_SOURCEMAPS=true
