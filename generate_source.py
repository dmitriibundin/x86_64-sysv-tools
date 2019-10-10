#!/usr/bin/python3.7
from dataclasses import dataclass
import re
import sys
import argparse
from pathlib import Path

#Convert C header files to nasm

NASM_INCLUDE_SUFFIX = ".inc"
DIRECTIVE_START_TOKEN = "#"
#Currently only #define directives are recognized
DIRECTIVE_PATTERN = "#(\t|\s)*define(\t|\s)*(([a-zA-Z0-9_]|[\u0024\u0040\u0060]|(?![\u0000-\u00A0]))*)((\t|\s)+(.*)|(\t|\s)*)"
SPLICE_PATTERN = "\\\\(\t|\s)*(\r\n|\r|\n)"

@dataclass
class DefineObject(object):
    macro_name: str
    macro_value: str

@dataclass
class NonDirectives(object):
    pp_tokens: str

class PreprocessingException(Exception):
    pass

class NonPreprocessorGroupPartException(PreprocessingException):
    def __init__(self, line):
        self.line = line
    
    def __str__(self):
        return repr(self.line)
    
#translation phase 2
def splice(header_file):
    return re.sub(SPLICE_PATTERN, '', header_file)

def parse_directive_line(directive_line):
    if not directive_line.startswith(DIRECTIVE_START_TOKEN):
        raise NonPreprocessorGroupPartException(directive_line)

    search = re.search(DIRECTIVE_PATTERN, directive_line, re.UNICODE)
    object_macro = None
    if search is not None:
        object_macro = DefineObject(macro_name = search.group(3), macro_value = search.group(7))

    return object_macro
    
def object_defines(header_file):
    spliced_header = splice(header_file)
    raw_directives = [line.strip() for line in spliced_header.splitlines() if line.startswith(DIRECTIVE_START_TOKEN)]

    return [directive for directive in [parse_directive_line(raw_directive) for raw_directive in raw_directives] if directive]

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Parse generator arguments')
    parser.add_argument("--c-header-nasm-inc-pairs", type=lambda str: [pair.split(':') for pair in str.split(',')],
            help="Comma-separated list of colon-separated pairs of source-c-header:destination-generated-nasm-inc, \
                    e.g. /path/file1.c:/generated/path/file2.inc,/another_path/file3.h:/another/generated/file4.inc, \
                    where all filenames and extensions are not restricted to those ende with 'h', 'c', or 'inc'.")
    args = parser.parse_args()
    
    if(len(sum(arg
    print(args.c_header_nasm_inc_pairs)

    print(flattened_dict)
    if(len(flattened_dict) > len(set(flattened_dict))):
        raise Exception("Non unique element encountered")

    #TODO: Validate the dictionary that it the c_header_path,nasm_header_path are all distinct
    for c_header_path, nasm_header_path in args.c_header_nasm_inc_pair:
        nasm_define_directives = [F"%define {object_define.macro_name} {object_define.macro_value or ''}" for object_define in object_defines(c_header_path)]
        with open(nasm_header_path, 'w+') as nasm_header_fd:
            nasm_header_fd.writelines(line + '\n' for line in nasm_define_directives)
