#!/usr/bin/bash
# Using OpenROAD-flow-scripts/build_openroad.sh as a template

set -eu

DIR="$(dirname $(readlink -f $0))"
cd "$DIR"


INSTALL_PATH="$(pwd)"


PROC=-1

function usage() {
        cat << EOF

Usage: $0 [-h|--help] [-o|--local] [-t|--threads N] [--clean] [--clean-force]

Options:
    -h, --help              Print this help message.

    -o, --local             Build locally instead of building a Docker image.

    -t, --threads N         Use N cpus when compiling software.

    --install-path PATH     Path to install tools. Default is ${INSTALL_PATH}.

    --clean                 Call git clean interactively before compile.
                            Also removes any files native to nyuzi.

    --clean-force           Call clean before compile. WARNING: this option
                            will not ask for confirmation.
EOF
}

# Parse arguments
__CMD="$0 $@"
while (( "$#" )); do
        case "$1" in
                -h|--help)
                        usage 2> /dev/null
                        exit
                        ;;
                -o|--local)
                        LOCAL_BUILD=1
                        ;;
                -t|--threads)
                        PROC="$2"
                        shift
                        ;;
                --install-path)
                        INSTALL_PATH="$2"
                        shift
                        ;;
                --clean)
                        CLEAN_BEFORE=1
                        ;;
                --clean-force)
                        CLEAN_BEFORE=1
                        CLEAN_FORCE=1
                        ;;
                -*|--*) # unsupported flags
                        echo "[ERROR FLW-0005] Unsupported flag $1." >&2
                        usage 2> /dev/null
                        exit 1
                        ;;
        esac
        shift
done

if [[ "$PROC" == "-1" ]]; then
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
                PROC=$(nproc --all)
        elif [[ "$OSTYPE" == "darwin"* ]]; then
                PROC=$(sysctl -n hw.ncpu)
        else
                cat << EOF
[WARNING FLW-0025] Unsupported OSTYPE: cannot determine number of host CPUs"
Defaulting to 2 threads. Use --threads N to use N threads"
EOF
  PROC=2
        fi
fi


__cleanup()
{
        if [ ! -z "${CLEAN_FORCE+x}" ]; then
                CLEAN_CMD="-x -d --force"
        else
                CLEAN_CMD="-x -d --interactive"
        fi
        echo "Cleaning up binaries and build files."
        git clean ${CLEAN_CMD} tools
        git submodule foreach --recursive git clean ${CLEAN_CMD}
        rm sv2v
}

if [ ! -z "${CLEAN_BEFORE+x}" ]; then
        __cleanup
fi

# Check if sv2v exists already (and set up if not)
if [ ! -f "./sv2v" ]; then
        echo "A local sv2v installation doesn't exist. Cloning and building..."
        rm -rf sv2v_main
        git clone https://github.com/zachjs/sv2v.git sv2v_main
        # Download haskell stack locally
        curl -sSL https://get.haskellstack.org/ | sh -s - -d $(pwd)/sv2v_main
        cd sv2v_main
        # Change default STACK_ROOT dir from ~/.stack to the current dir
        export STACK_ROOT=$(pwd)/sv2v_main
        ./stack setup
        ./stack build
        cp "$(./stack path --local-install-root)/bin/sv2v" ../sv2v
        cd ..
        rm -rf sv2v_main
        echo "Local sv2v build completed!"
else
        echo "sv2v already present in directory"     
fi

