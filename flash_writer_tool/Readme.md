## Program Bootloaders using internal ROM and Flashwriter

---

### Description
This script simplifies the loading of the IPL onto the RZV2MA Evaluation board. The directions below assume that you have already performed the  RZV2MA yocto build.  The following files should have been generated

- loader_1st_128kb.bin
- loader_2nd.bin
- loader_2nd_param.bin
- u-boot.bin
- u-boot_param.bin


### Using the Command Line Interface

To use this script for commandline operation doe the following.

**Step 1)** Navigate to the directory where the RZV2MA kernal, filesystem, and ipl files  are deployed.  Below is example of wher this is.

```
    /rzv2ma/build/tmp/deploy/images/rzv2ma
```
**Step 2)** Copy this script to that directory

**Step 3)** Set the script as executable

```
	chmod +x Flash_loader.sh
```
**Step 4)** Execute the following command.

```
   ./Flash_loader.sh .
```