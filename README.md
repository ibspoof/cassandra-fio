## Cassandra Fio

This project has a collection of Fio tests that emulate Cassandra's read and write patterns for both STCS and LCS compaction strategies. There is a bash script `fio_runner.sh` that both runs the tests and if gnuplot is installed will generate svg reports for the read/write patterns.

There are both LCS and STCS configurations that will target Cassandra's SSTable file size and concurrent compaction settings.  LCS configurations will create 10 files of size 160mb with one write a time and random reads across 5 files at a time whereas STCS will create 10 files of random size between 150mb and 5g with 2 files written at a time and random reads across 5 files.

### Usage
Each individual test can be run manually using `fio {fioFile}` or through the `fio_runner.sh`.  By default the `fio_runner.sh`  will run all of the `.fio` files in the local directory. Passing one of the following options will limit the tests to the appropriate fio configs:
- `fio_runner.sh 32k`
- `fio_runner.sh 64k`
- `fio_runner.sh lcs`
- `fio_runner.sh stcs`
- `fio_runner.sh all`

If fio is manually compiled and is not in the default bin directories the path to the binary can be passed in the second argument. Example: `fio_runner.sh all /opt/fio/fio`

All data files are written to the local `./data` directory and after each run are auto-deleted to avoid space usage.    Fio output logs are saved to the `./logs` directory.  Run outputs are saved to the local `./reports` directory.

If a `./logs` directory or `./report` exists when the runner script is started, they will be archived to a new directory using the current epoch timestamp i.e. `logs_1485634043`.

### Output Graphs
If `fio_generate_plots` is installed the throughput (bandwith), latency and iops reports will found in `./logs` will be auto generated and stored in the `./reports` directory after all tests are completed. All read and write reports will be grouped together for each run in the same output files.

Example Graph:
![alt tag](docs/imgs/All-Writes-bw.svg.png?raw=true)

### Modifying configurations
See either of the `lcs.*.fio` files to view all the config settings and documentation on all of the settings and alternative options.

### Requirements
- [fio 2.1.x+](https://github.com/axboe/fio)
- fio_generate_plots/gnuplot (optional)

### Extras
Special thanks to [@tobert](https://github.com/tobert/) for his Cassandra fio configuration examples used as the starter for this project.
