#!/usr/bin/python3.7

import argparse
from pathlib import Path

NASM_INCLUDE_SUFFIX=".inc"
CMAKE_LIST_SEPARATOR= " "

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Prepare auto generated source file names")
    parser.add_argument('--headers-c-to-nasm', help=": (colon) separated list of absolute paths", type=lambda s: [item for item in s.split(':')], required=True)
    parser.add_argument('--nasm-include-dir', help="Directory where the generated nasm inc files will be stored", type=str, required=True)
    args = parser.parse_args()

    generated_names = [str(Path(args.nasm_include_dir, Path(input_header).stem).with_suffix(NASM_INCLUDE_SUFFIX)) for input_header in args.headers_c_to_nasm]
    print(CMAKE_LIST_SEPARATOR.join(generated_names))
