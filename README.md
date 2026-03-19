# HighTide

There are two ways to build designs: the **Bazel flow** (recommended) or the legacy **Make flow**.

## Bazel Flow (recommended)

### Prerequisites

- Ubuntu 24.04 (or other Linux distribution supported by ORFS)
- Docker (used by bazel-orfs to extract OpenROAD tools from the ORFS image)

### Getting Started

1. Install dependencies:

```bash
sudo apt install perl
sudo wget -O /usr/local/bin/bazel https://github.com/bazelbuild/bazelisk/releases/latest/download/bazelisk-linux-amd64
sudo chmod +x /usr/local/bin/bazel
```

2. Clone this repository:

```bash
git clone git@github.com:VLSIDA/HighTide.git
cd HighTide
```

3. Build a design:

```bash
bazel build //designs/asap7/lfsr_prbs_gen:lfsr_prbs_gen_final
```

No additional setup is needed. Bazel automatically fetches ORFS and bazel-orfs via `MODULE.bazel`.

### Build Commands

```bash
# Build a single design (full RTL-to-GDSII flow)
bazel build //designs/asap7/lfsr_prbs_gen:lfsr_prbs_gen_final

# Build all designs for a platform
bazel build //designs/asap7/...

# Build all designs across all platforms
bazel build //designs/...

# Build individual stages
bazel build //designs/asap7/lfsr_prbs_gen:lfsr_prbs_gen_synth
bazel build //designs/asap7/lfsr_prbs_gen:lfsr_prbs_gen_floorplan
bazel build //designs/asap7/lfsr_prbs_gen:lfsr_prbs_gen_place
bazel build //designs/asap7/lfsr_prbs_gen:lfsr_prbs_gen_cts
bazel build //designs/asap7/lfsr_prbs_gen:lfsr_prbs_gen_route
```

### Dev RTL Generation (Bazel)

By default, designs use pre-generated Verilog. To regenerate RTL from source repositories:

1. Initialize the design's submodule:
```bash
git submodule update --init designs/src/<design>/dev/repo
```

2. Build with dev mode enabled:
```bash
bazel build --define update_rtl=true //designs/asap7/lfsr_prbs_gen:lfsr_prbs_gen_final
```

Some designs require additional tools (sv2v, sbt, litex) on PATH for dev generation.

## Make Flow (legacy)

### Getting Started

1. Clone this repository:

```bash
git clone git@github.com:VLSIDA/HighTide.git
cd HighTide
```

2. Run the setup to clone ORFS as a submodule and link the settings:

```bash
./setup.sh
```

3. [Run ORFS](https://vlsida.github.io/chip-tutorials/orfs-installation.html#run-orfs-docker-image) (this will run the Docker image corresponding to our submodule):

```bash
./runorfs.sh
```

4. Run a design in the Docker image:

```bash
make DESIGN_CONFIG=./designs/nangate45/lfsr_prbs_gen/config.mk
```

### Dev RTL Generation (Make)

By default, the suite will run using Verilog that has already been generated from its respective source (just like in ORFS). If the user wishes to amend changes to source files, the command `make update-rtl` should be used.
- `make update-rtl` will perform the generation of Verilog from the source repo (it will also do any prerequisite installation as well).
- The development folder for each design can be found under `designs/src/<DESIGN_NAME>/dev`

## Goal/Objectives

GOAL: Port open source designs to asap7/sky130/nangate45 technologies using ORFS, as a benchmark suite for ML projects.

Objective 1: Setup github CI/CD (to work with google cloud compute engine)

Objective 2: Formulate testbenches to verify the functionality of designs post-flow completion.

Objective 3: Expand suite by creating various versions of designs that fail at specific parts of the flow.

## Resources

In order to change (or update) the UCSC_ML_suite repository, you'll need to submit a pull request. For more information on submitting a PR, see [here](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request).
