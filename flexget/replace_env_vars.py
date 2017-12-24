#!/usr/bin/env python
import os
import argparse

parser = argparse.ArgumentParser(description='Replace environment variable tokens ${token} in file.')
parser.add_argument('--input_file', required=True, help="Input file with tokens.")
parser.add_argument('--output_file', required=True, help="Output file to write input file with replaced tokens")
args = parser.parse_args()

input_file = args.input_file
output_file = args.output_file

# Create a hash of tokens to values based on environment variables
replacements = dict()
for env in os.environ.keys():
    new_key = "${{{}}}".format(env)
    replacements[new_key] = os.environ[env]

new_lines = []
# Create a list of lines with tokens replaced
with open(input_file, 'r') as in_fh:
    print "Reading file: {}".format(input_file)
    line_number = 0
    for line in in_fh.readlines():
        line_number += 1
        for token in replacements:
            replaced_line = line.replace(token, replacements[token])
            if replaced_line is not line:
                print "Replaced {} on line {}.".format(token, line_number)
                line = replaced_line
        new_lines.append(line)

with open(output_file, 'w') as out_fh:
    print "Writing output to {}.".format(output_file)
    out_fh.writelines(new_lines)

