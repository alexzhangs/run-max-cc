# run-max-cc

Run a command in maximum N concurrent processes.

## Installation

```
git clone https://github.com/alexzhangs/run-max-cc
```

## Usage

Example, below syntax insure that command `dispatcher.sh foo bar` won't be
run concurrently.

```
bash run-max-cc/run-max-cc.sh -n 1 -p 'dispatcher.sh foo bar' dispatcher.sh
foo bar
```

See help:

```
bash run-max-cc/run-max-cc.sh -h
```
