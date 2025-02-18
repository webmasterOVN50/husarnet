#!/bin/bash
source $(dirname "$0")/../../util/bash-base.sh

if [ ! "$#" -eq 1 ]; then
    echo "Usage: $0 <architecture>"
    exit 1
fi

platform=unix
arch=$1

platform_base=${base_dir}/platforms/${platform}

${base_dir}/daemon/build.sh ${platform} ${arch}
${base_dir}/cli/build.sh ${platform} ${arch}

# Package
package_tmp=${build_base}/${platform}/${arch}/package
mkdir -p ${package_tmp}

mkdir -p ${package_tmp}/lib/systemd/system
cp ${platform_base}/packaging/husarnet.service ${package_tmp}/lib/systemd/system/

mkdir -p ${package_tmp}/usr/share/bash-completion/completions
cp ${platform_base}/packaging/autocomplete ${package_tmp}/usr/share/bash-completion/completions/husarnet

mkdir -p ${package_tmp}/usr/bin
cp ${release_base}/husarnet-daemon-${platform}-${arch} ${package_tmp}/usr/bin/husarnet-daemon
cp ${release_base}/husarnet-${platform}-${arch} ${package_tmp}/usr/bin/husarnet

for package_type in tar deb rpm; do
    echo "[HUSARNET BS] Building ${platform} ${arch} ${package_type} package"

    fpm \
        --input-type dir \
        --output-type ${package_type} \
        --name husarnet \
        --version ${package_version} \
        --epoch 1 \
        --architecture ${arch} \
        --maintainer "Husarnet <support@husarnet.com>" \
        --vendor Husarnet \
        --description "Global LAN network" \
        --url "https://husarnet.com" \
        $(if [ "${package_type}" == "deb" ]; then echo "--depends iproute2 --deb-recommends sudo --deb-recommends systemd --deb-recommends fonts-noto-color-emoji"; fi) \
        $(if [ "${package_type}" == "rpm" ]; then echo "--depends iproute --depends procps-ng"; fi) \
        --replaces "husarnet-ros" \
        --after-install ${platform_base}/packaging/post-install-script.sh \
        --after-remove ${platform_base}/packaging/post-remove-script.sh \
        --package ${release_base}/husarnet-${platform}-${arch}.${package_type} \
        --force \
        --chdir ${package_tmp}

done
