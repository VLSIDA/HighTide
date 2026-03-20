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
                            Also removes any files native to minimax.

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

__logging()
{
        local log_file="minimax_setup.log"
        echo "Saving logs to ${log_file}"
        echo "$__CMD"
        exec > >(tee -i "${log_file}")
        exec 2>&1
}

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

__logging
if [ ! -z "${CLEAN_BEFORE+x}" ]; then
        __cleanup
fi

# Check if sv2v exists already (and set up if not)
if [ ! -f "${INSTALL_PATH}/sv2v" ]; then
        echo "sv2v not found. Downloading prebuilt binary..."
        SV2V_ZIP="sv2v-Linux.zip"
        curl -sSL -o "$SV2V_ZIP" \
            "https://github.com/zachjs/sv2v/releases/download/v0.0.13/sv2v-Linux.zip"
        unzip -o "$SV2V_ZIP" -d sv2v_extract
        cp sv2v_extract/sv2v-Linux/sv2v "${INSTALL_PATH}/sv2v"
        chmod +x "${INSTALL_PATH}/sv2v"
        rm -rf "$SV2V_ZIP" sv2v_extract
        echo "sv2v binary downloaded successfully!"
else
        echo "sv2v already present in directory"     
fi


