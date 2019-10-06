#!/usr/bin/python3.7

import pip

def install_package(package_name):
    print(f"Installing {package_name}...")
    if hasattr(pip, 'main'):
        pip.main(['install', package_name])
    else:
        pip._internal.main(['install', package_name])
    print(f"Package {package_name} installed successfully")

if __name__ == "__main__":
#    install_package("pcpp")