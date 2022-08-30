#!/bin/bash -ex

# Get build target
DIST=$(schroot -i | fgrep ' Aliases ' | head -1 | awk '{print $2}' || :)
ARCH=$(schroot -i | fgrep ' Name ' | head -1 | awk -F'-' '{print $2}' || :)
HOST_ARCH=$(dpkg --print-architecture)

if [ "$(id -u)" == "0" ] ; then
    if [ "${ARCH}" != "${HOST_ARCH}" ] ; then
        # FIXME: hardcode for arm64
        # Somehow next command enables all formats instead of selected one
        update-binfmts --enable qemu-aarch64
        update-binfmts --display \
            | grep '^[^ ]' \
            | awk '{print $1}' \
            | xargs -I% update-binfmts --disable %
        # Second run enables selected format only
        update-binfmts --enable qemu-aarch64
    fi
    NEW_UID=$(stat --printf='%u' /srv/source)
    usermod -u ${NEW_UID} abuild
    su abuild -c "$0"
    exit $?
fi

# Test chroot
schroot -l
schroot -i -c "${DIST}"

sbuildOpts=''
buildResultDir='/srv/build/'
keyDir='/srv/keys/'
sourceDir='/srv/source/'

[ ! -d "${keyDir}" ] \
    && keyDir=$(mktemp -d)

# `test -f` works fine with globs if there is the only
# glob match
# shellcheck disable=SC2144
if [ -f "${sourceDir}"/*.dsc ] ; then
    sourceDir="${sourceDir}/*.dsc"
elif [ ! -d "${sourceDir}/debian" ] ; then
    sourceDir="${sourceDir}/*/"
fi

# Fill out extra repo params
if [ -n "${EXTRA_REPO}" ] ; then
    OIFS="$IFS"
    IFS='|'
    for repo in ${EXTRA_REPO} ; do
        if [ "${repo%% *}" == 'deb' ] ; then
            sbuildOpts="${sbuildOpts} --extra-repository \"${repo}\""
            # Trying get signing keys
            repoUrl=$(echo "${repo}" | awk -F' ' '{print $2}')
            keyList=$(wget -qO - "${repoUrl}" \
                | awk -F'[<>]' '{print $3}' | egrep '\.key|asc$' || :)
            while read -r keyFile ; do
                wget -qO "${keyDir}/${keyFile}.key" "${repoUrl}/${keyFile}" || :
            done < <( echo "${keyList}" )
        fi
    done
    IFS="$OIFS"
fi

# Fill out extra repo key params
gpg --list-keys &>/dev/null
for keyFile in ${keyDir}/*.key ; do
    gpg --dry-run --import "${keyFile}" &>/dev/null \
        && sbuildOpts="${sbuildOpts} --extra-repository-key \"${keyFile}\""
done

ARCH_OPTS=''
[ "${ARCH}" != "${HOST_ARCH}" ] \
    && ARCH_OPTS="--arch ${ARCH} --no-arch-all"

# Run build
## Install additional packages for Percona and upgrade cmake
bash -c "
  DEB_BUILD_OPTIONS=nocheck \
        /usr/bin/sbuild \
        ${ARCH_OPTS} \
        --dist ${DIST} \
        --source \
        --force-orig-source \
        --chroot-setup-commands=\"apt-get update\" \
        --chroot-setup-commands=\"apt-get upgrade -f -y --force-yes\" \
        \
        --chroot-setup-commands=\"echo '[i] Add additional steps for percona build'\" \
        \
        --chroot-setup-commands=\"apt-get install -y libcurl4-openssl-dev vim-common wget\" \
        --chroot-setup-commands=\"wget https://github.com/Kitware/CMake/releases/download/v3.24.0/cmake-3.24.0-linux-x86_64.sh -O cmake.sh\" \
        --chroot-setup-commands=\"chmod +x ./cmake.sh && mkdir /opt/cmake && ./cmake.sh --prefix=/opt/cmake --skip-license\" \
        --chroot-setup-commands=\"ln -s /opt/cmake/bin/cmake /usr/local/bin/cmake && cmake --version\" \
        ${sbuildOpts} \
        ${sourceDir}
"

cd "${buildResultDir}"
dpkg-scanpackages . > Packages
