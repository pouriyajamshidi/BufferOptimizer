# Linux Buffer Optimizer

I was called in to check a Linux VPS on a cloud provider that was having a great amount of continuous RX drops. After a lot of digging, I realized the culprit was the receive buffer size. After a couple of failed attempts to find a suitable value by hand, I decided to write a script to find the best value for that machine and decided to share it with the community.

This script, will get the current value of supported RX buffer and what is already set. Increases the buffer size, checks for RX drops for a while and if drops are not stopped, it will continue increasing the size.

This script might not be safe for all the environments to use. **Make sure you know whar you are doing before running it**.

Use it only if you are certain the cause of your RX drops is indeed, RX buffer size. **Increasing the buffer size blindly will cause increased latency and bufferbloat**

## Requirements

```ethtool``` utility has to be installed on your server.

## Usage

```bash
chmod +x bufferoptimizer.sh

```

And run it like:

```bash
sudo ./bufferoptimizer.sh <interface> <initial buffer size>
```

Example:

```bash
sudo ./bufferoptimizer.sh eth0 128
```

## Tested on

Ubuntu server 18.04

## Contributing

Pull requests are welcome.

## License

[![GPL license](https://img.shields.io/badge/License-GPL-blue.svg)](http://perso.crans.org/besson/LICENSE.html)
