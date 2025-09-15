#! /bin/bash
# I used it for livgrep
cd $WSROOT
wget https://github.com/bazelbuild/bazel/releases/download/5.3.2/bazel-5.3.2-installer-linux-x86_64.sh
chmod  755 bazel-5.3.2-installer-linux-x86_64.sh
./bazel-5.3.2-installer-linux-x86_64.sh --user=$PWD
export PATH=$PATH:$WSROOT/bin/
mkdir -p $WSROOT/bin/.cache
echo "startup --output_user_root=$WSROOT/bin/.cache" >> ~/.bazelrc
