# smidot
SMILES visualization with Godot


## 2D

![](Images/2d_base.png)
![](Images/2d_highlight.png)

## 3D

![](Images/3d_base.png)
![](Images/3d_highlight.png)

## Installation of source code in godot

1. Download the source code from the repository
`git clone https://github.com/ualibweb/smidot.git`
2. Open Godot and click on `Import`
3. Navigate to the `smidot` folder and click on `Open` on the `project.godot` file

### To run the program

1. In the Godot editor, click on the `Play` button to run `►` the program on the top right corner of the window. 

## Installation of binaries

For Ubuntu and Debian systems, install the base `.zip`
For Arm Linux systems like Raspi, install the `arm.zip`
For Windows systems, install the `exe.zip`

---

For the program to run, you must have Python 3.7 or greater installed and Python virtual environments installed.

To install and prepare your systems for running a program that requires Python 3.7 or greater and Python virtual environments, follow these steps tailored to each system type:

### Ubuntu/Debian Systems or Arm Linux Systems (like Raspberry Pi)

**Install Python 3.7 or greater and Virtual Environment**:
   - Most modern Ubuntu/Debian systems come with Python 3 already installed. You can check your Python version by running:
     ```bash
     python3 --version
     ```
   - If you don't have Python 3.7 or greater, install it:
     ```bash
     sudo apt-get install python3.7
     ```
   - Install `python3-venv` to use virtual environments:
     ```bash
     sudo apt-get install python3-venv
     ```

### Windows Systems

1. **Install Python 3.7 or greater**:
   - Download the Python installer from the [official Python website](https://www.python.org/downloads/). Make sure to download a version that is 3.7 or greater.
   - Run the installer. Ensure you check the box that says "Add Python 3.x to PATH" to make Python accessible from the command line.

2. **Install Virtual Environment**:
   - Open Command Prompt and install the virtual environment package:
     ```cmd
     pip install virtualenv
     ```

These instructions will guide you through installing the necessary software and setting up a Python virtual environment, which is essential for running Python-based applications securely and without interfering with system-wide Python packages.