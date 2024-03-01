# SmiNav
### SMILES visualization with Godot

SmiNav (SMILES Navigator) is a GUI visualizer for parts of the SMILES syntax. It was inspired by Andrew Dalke's [smiview](https://hg.sr.ht/~dalke/smiview). It uses the [RDKit](https://www.rdkit.org/) library in python to parse the SMILES string and return data that is then used to create a 2D or 3D visualization of the molecule. The visualization is done using the Godot game engine.

## Main Screen

![](Images/MainScreen.png)

## 2D

![](Images/2D.png)

## 3D

![](Images/3D.png)

## Installation of source code in godot

1. Download the source code from the repository
`git clone https://github.com/ualibweb/sminav.git`
2. Open Godot and click on `Import`
3. Navigate to the `SmiNav` folder and click on `Open` on the `project.godot` file

### To run the program

In the Godot editor, click on the `Play` button to run `►` the program on the top right corner of the window.

## Installation of binaries

For Ubuntu and Debian systems, install the base `SmiNav_Linux.zip`

For Arm64 Linux systems like Raspi, install the `SmiNav_LinuxArm.zip`

For Windows systems, install the `SmiNav_Windows.zip`

### Running Binaries

1. Linux x86 - Open binary in file navigator or start from terminal (e.g., ./SmiNav.x86_64)

2. Linux ARM64 - Open binary in file navigator or start from terminal with (e.g., ./SmiNav.arm64)
     - If needed, use opengl3-es, ./SmiNav.arm64 --rendering-driver opengl3_es

3. Windows - Click on SmiNav.exe

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

## Advanced Installation

### Manually Setting Up a Virtual Environment

If you prefer to manually set up a virtual environment, follow these steps:

1. **Create a Virtual Environment**:
   - Open a terminal or command prompt and navigate to the project directory.
   - Run the following command to create a virtual environment (Windows users should replace `python3` with `python`):
     ```bash
     python3 -m venv .venv
     ```
   - This will create a new directory called `.venv` in your project folder. This directory contains a local Python environment that is isolated from your system-wide Python installation.
2. **Activate the Virtual Environment**:
   - Once the virtual environment is created, you need to activate it. Run the following command:
     - On Ubuntu/Debian:
       ```bash
       source .venv/bin/activate
       ```
     - On Windows:
       ```cmd
       .venv\Scripts\activate
       ```
   - When the virtual environment is activated, your terminal or command prompt will show the name of the environment at the beginning of the command line. This indicates that you are now working within the virtual environment.
3. **Install Dependencies**:
    - With the virtual environment activated, you can install the required Python packages using `pip`. Run the following command:
      ```bash
      pip install rdkit
      ```
    - This will install all the necessary Python packages for the project within the virtual environment, ensuring that they do not interfere with your system-wide Python installation.
  

### FAQ

1. If Python dependencies installation fails, delete .venv in /smiNav folder before trying again. Typical failure is not having Python 3 or Python venv installed.

