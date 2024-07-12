#!/bin/bash
declare -A REPO REMOTE
PREFIXES=(nvidia nvidia/nvgpu nvidia/soc/tegra nvidia/soc/t19x nvidia/soc/t210 \
		 nvidia/platform/tegra/common \
		 nvidia/platform/t18x/common nvidia/platform/t18x/lanai nvidia/platform/t18x/quill \
		 nvidia/platform/t19x/common nvidia/platform/t19x/galen/kernel-dts nvidia/platform/t19x/jakku/kernel-dts nvidia/platform/t19x/mccoy/kernel-dts nvidia/platform/t19x/galen-industrial/kernel-dts \
		 nvidia/platform/t210/common nvidia/platform/t210/jetson nvidia/platform/t210/porg nvidia/platform/t210/batuu/kernel-dts)


NVSRCROOT=$(dirname $(readlink -f "$0"))

REPO[nvidia]="sources/kernel/nvidia"
REPO[nvidia/nvgpu]="sources/kernel/nvgpu"
REPO[nvidia/soc/tegra]="sources/hardware/nvidia/soc/tegra"
REPO[nvidia/soc/t18x]="sources/hardware/nvidia/soc/t18x"
REPO[nvidia/soc/t19x]="sources/hardware/nvidia/soc/t19x"
REPO[nvidia/soc/t210]="sources/hardware/nvidia/soc/t210"
REPO[nvidia/platform/tegra/common]="sources/hardware/nvidia/platform/tegra/common"
REPO[nvidia/platform/t18x/common]="sources/hardware/nvidia/platform/t18x/common"
REPO[nvidia/platform/t18x/lanai]="sources/hardware/nvidia/platform/t18x/lanai"
REPO[nvidia/platform/t18x/quill]="sources/hardware/nvidia/platform/t18x/quill"
REPO[nvidia/platform/t19x/common]="sources/hardware/nvidia/platform/t19x/common"
REPO[nvidia/platform/t19x/galen/kernel-dts]="sources/hardware/nvidia/platform/t19x/galen/kernel-dts"
REPO[nvidia/platform/t19x/jakku/kernel-dts]="sources/hardware/nvidia/platform/t19x/jakku/kernel-dts"
REPO[nvidia/platform/t19x/mccoy/kernel-dts]="sources/hardware/nvidia/platform/t19x/mccoy/kernel-dts"
REPO[nvidia/platform/t19x/galen-industrial/kernel-dts]="sources/hardware/nvidia/platform/t19x/galen-industrial-dts/kernel-dts"
REPO[nvidia/platform/t210/common]="sources/hardware/nvidia/platform/t210/common"
REPO[nvidia/platform/t210/jetson]="sources/hardware/nvidia/platform/t210/jetson"
REPO[nvidia/platform/t210/porg]="sources/hardware/nvidia/platform/t210/porg"
REPO[nvidia/platform/t210/batuu/kernel-dts]="sources/hardware/nvidia/platform/t210/batuu/kernel-dts"

REMOTE[nvidia]="linux-nvidia"
REMOTE[nvidia/nvgpu]="linux-nvgpu"
REMOTE[nvidia/soc/tegra]="soc-tegra"
REMOTE[nvidia/soc/t18x]="soc-t18x"
REMOTE[nvidia/soc/t19x]="soc-t19x"
REMOTE[nvidia/soc/t210]="soc-t210"
REMOTE[nvidia/platform/tegra/common]="platform-tegra-common"
REMOTE[nvidia/platform/t18x/common]="platform-t18x-common"
REMOTE[nvidia/platform/t18x/lanai]="platform-t18x-lanai"
REMOTE[nvidia/platform/t18x/quill]="platform-t18x-quill"
REMOTE[nvidia/platform/t19x/galen/kernel-dts]="platform-t19x-galen-dts"
REMOTE[nvidia/platform/t19x/jakku/kernel-dts]="platform-t19x-jakku-dts"
REMOTE[nvidia/platform/t19x/mccoy/kernel-dts]="platform-t19x-mccoy-dts"
REMOTE[nvidia/platform/t19x/galen-industrial/kernel-dts]="platform-t19x-galen-industrial-dts"
REMOTE[nvidia/platform/t19x/common]="platform-t19x-common"
REMOTE[nvidia/platform/t210/common]="platform-t210-common"
REMOTE[nvidia/platform/t210/jetson]="platform-t210-jetson"
REMOTE[nvidia/platform/t210/porg]="platform-t210-porg"
REMOTE[nvidia/platform/t210/batuu/kernel-dts]="platform-t210-batuu"

BRANCH="l4t/l4t-r32.7.5"

usage() {
    cat <<EOF

Usage:

    `basename $0` <local-branch>

	local-branch: name for local unified branch (default: patches-l4t-rXX.X)

Options:

    -b <remote-branch>	Name of L4T source branch to sync to (default: $BRANCH)
    -h                  Display this help    

EOF

}


while getopts ":b:h" opt; do
    case $opt in
	h)
	    usage
	    exit 0
	    ;;
	b)
	    BRANCH="$OPTARG"
	    ;;
	\?)
	    usage
	    exit 1
	    ;;
    esac
done
shift `expr $OPTIND - 1`

MYBRANCH="$1"
if [ -z "$1" ]; then
    MYBRANCH="oe4t-patches-`echo $BRANCH | awk -F/ '{print $2}'`"
fi

echo "L4T branch:   $BRANCH"
echo "local branch: $MYBRANCH"

# Start by making sure that the remotes are in place and
# up-to-date

if git remote | grep -q '^nv49'; then
    git remote set-url nv49 ${NVSRCROOT}/sources/kernel/kernel-4.9
else
    git remote add nv49 ${NVSRCROOT}/sources/kernel/kernel-4.9
fi
git fetch nv49

git checkout -b $MYBRANCH nv49/${BRANCH}-4.9

for pfx in ${PREFIXES[@]}; do
    if git remote | grep -q "^${REMOTE[$pfx]}"; then
	git remote set-url ${REMOTE[$pfx]} ${NVSRCROOT}/${REPO[$pfx]}
    else
	git remote add ${REMOTE[$pfx]} ${NVSRCROOT}/${REPO[$pfx]}
    fi
    git fetch ${REMOTE[$pfx]}
done

# Now read-tree in the subtrees

set -e
for pfx in ${PREFIXES[@]}; do
    git merge -s ours --no-commit --allow-unrelated-histories -Xsubtree="$pfx" ${REMOTE[$pfx]}/$BRANCH
    git read-tree --prefix=$pfx/ -u ${REMOTE[$pfx]}/$BRANCH
    git commit -m "Import subtree $pfx from ${REMOTE[$pfx]}/$BRANCH"
    git pull -s subtree -Xsubtree="$pfx" ${REMOTE[$pfx]} $BRANCH
    #git merge -Xsubtree="$pfx" --allow-unrelated-histories -m "Import subtree $pfx from ${REMOTE[$pfx]}/$BRANCH" ${REMOTE[$pfx]}/$BRANCH
    #git subtree add -d --prefix=$pfx ${REMOTE[$pfx]} $BRANCH -m "Import subtree $pfx from ${REMOTE[$pfx]}/$BRANCH"
    #git subtree merge -d --prefix=$pfx ${REMOTE[$pfx]}/$BRANCH 
done
