<img src="docs/images/HighTideLogo.svg" width="900"/>


## About

HighTide is a dual-environment dynamic hardware design suite (built around [OpenROAD-flow-scripts](https://github.com/The-OpenROAD-Project/OpenROAD-flow-scripts)) comprising designs that are representative of the continually evolving open-source design space. The suite tracks periodic updates to each design in the suite and will continue to add designs as they emerge from the open-source community.

## Setup

1. Clone this repository:

```bash
git clone git@github.com:VLSIDA/HighTide.git
```

2. Run the setup to clone ORFS as a submodule and link the settings:

```bash
cd HighTide
./setup.sh
```

3. Run ORFS (this will run the Docker image corresponding to our ORFS submodule tag):

```bash
./runorfs.sh
```

4. Run the default design (`asap7/minimax`) in the Docker image:

```bash
make
```
## Suite Designs

<table>
  <thead>
    <tr>
      <th>Design</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><a href="https://github.com/enjoy-digital/liteeth"><b>LiteEth</b></a></td>
      <td>Configurable Ethernet core IP</td>
    </tr>
    <tr>
      <td><a href="https://github.com/gsmecher/minimax"><b>Minimax</b></a></td>
      <td>Compressed-first, micro-coded RISC-V CPU</td>
    </tr>
    <tr>
      <td><a href="https://nvdla.org/"><b>NVDLA-small</b></a></td>
      <td>Scalable and configurable deep learning accelerator</td>
    </tr>
    <tr>
      <td><a href="https://github.com/google-coral/coralnpu"><b>coralnpu</b></a></td>
      <td>Hardware accelerator (scalar-only) for ML inference</td>
    </tr>
    <tr>
      <td><a href="https://github.com/ucb-bar/gemmini"><b>gemmini</b></a></td>
      <td>Deep neural network (DNN) accelerator</td>
    </tr>
    <tr>
      <td><a href="https://github.com/black-parrot/black-parrot"><b>BlackParrot</b></a></td>
      <td>RV64GC+ multicore processor with multi-core configs</td>
    </tr>
    <tr>
      <td><a href="https://github.com/vortexgpgpu/vortex"><b>Vortex</b></a></td>
      <td>General-purpose GPU (GPGPU) processor</td>
    </tr>
    <tr>
      <td><a href="https://github.com/ucb-bar/sha3"><b>sha3</b></a></td>
      <td>SHA-3 (Keccak) cryptographic hash datapath</td>
    </tr>
    <tr>
      <td><a href="https://github.com/NNgen/nngen"><b>NNGen</b></a></td>
      <td>Generated convolutional neural network (CNN)</td>
    </tr>
  </tbody>
</table>

## `update_rtl` feature 

By default, the suite will run using verilog that has already been generated from its respective source (just like in ORFS). If the user wishes to amend changes from source files to update the Verilog RTL, the command `make update_rtl` should be used.

- `make update_rtl` will perform Verilog RTL generation from a design's source (setting up any necessary prerequisite installation as well).
- The development folder for each design can be found under `src/<DESIGN_NAME>/dev`

This option can also be used by those in the open-source community interested in adding a design to the suite. More information about adding a design using `update_rtl`, can be found in the [design document](docs/devdesign.md).



<!-- ## Resources

For more information regarding per-snapshot design statistics, changelogs, and extra suite information, visit [the HighTide suite HomePage](). 

-->