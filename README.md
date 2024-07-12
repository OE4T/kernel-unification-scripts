L4T kernel unification scripts
==============================

The `l4t-unify.sh` script is used to pull together the multiple repos
NVIDIA hosts for Jetson Linux (pre-R36) into a single tree, such as the
one at https://github.com/OE4T/linux-tegra-4.9 .

Start by using the `source_sync.sh` in the L4T kit to populate the
various source trees from NVIDIA's repos.  Then copy the scripts here
into the `Linux_for_Tegra` directory.

Make sure the synced repos are on the right branch by using `find`
with the `docheckout.sh` script:

      $ find sources -type d -name .git -exec $PWD/docheckout.sh {} \;

Next, initialize a git workspace for your unified kernel tree, and run
the `l4t-unify.sh` script to populate the subtrees in your new workspace
from the contents you downloaded above.

You will then need to apply a patch like
[this one](https://github.com/OE4T/linux-tegra-4.9/commit/89b04485a4d3fa40431fe5a343480aa11c1c1985)
to rework the modifications NVIDIA made to the kernel build
system for the unified layout.

If you use the Yocto Project's kernel tools, you'll also need a
modification to support the "overlay" approach NVIDIA took for its
drivers. See [this recipe](https://github.com/OE4T/meta-tegra/blob/kirkstone-l4t-r32.7.x/recipes-kernel/kern-tools/kern-tools-tegra-native_git.bb).

Use at your own risk.  The script is not likely to be reusable, even across L4T
versions, without modification.
