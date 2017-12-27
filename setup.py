#!/usr/bin/env python
"""Script to setup required environment vars. """
from __future__ import print_function
import sys
import re
from collections import defaultdict
import os.path
from os.path import isfile, dirname, realpath
from glob import glob

RE_ENV = re.compile(r'^(?P<var_name>[a-z0-9_-]+)=(?P<var_value>.*)$', re.IGNORECASE)


def get_default_and_override_files(path):
    """Return list of tuples with default and override env files."""
    env_files = []
    for default_file in glob(os.path.join(path, '*.default.env')):
        # Get .<?>.user.env for <?>.default.env
        (user_path, user_filename) = os.path.split(default_file)
        user_filename = user_filename.replace('default', 'user')
        user_filename = '.' + user_filename
        user_file = os.path.join(user_path, user_filename)
        env_files.append((default_file, user_file))
    return env_files


def get_user_values(user_file):
    """Read file in and turn var=value into a dict we return."""
    var2value = defaultdict()
    if isfile(user_file):
        with open(user_file, 'r') as user_fh:
            lines = user_fh.readlines()
        for line in lines:
            match = RE_ENV.match(line)
            if match:
                var2value[match.groupdict()['var_name']] = match.groupdict()['var_value']
    return var2value


def update_overrides(default_file, user_file):
    """Update var=value in user_file using default_file for defaults."""
    user_overrides = get_user_values(user_file)
    with open(default_file, 'r') as default_fh:
        lines = default_fh.readlines()
    new_lines = []
    for line in lines:
        line = line.rstrip()
        match = RE_ENV.match(line)
        if not match:
            print(line)
            new_lines.append(line)
        else:
            var_name = match.groupdict()['var_name']
            var_value = match.groupdict()['var_value']
            if var_name in user_overrides:
                var_value = user_overrides[var_name]
            print('{}={}'.format(var_name, var_value))
            new_value = raw_input("\tEnter new value for '{}' [Enter to keep value]: ".format(var_name, var_value))
            if new_value:
                var_value = new_value.rstrip()
                print("\tSet '{}' to '{}'".format(var_name, var_value))
            else:
                print("\tNo change.")
            new_lines.append('{}={}'.format(var_name, var_value))
    with open(user_file, 'w') as user_fh:
        print("Writing changes to {}".format(user_file))
        user_fh.write("\n".join(new_lines))


def update_all_overrides(path):
    """Update/write .*.user.env by reading missing values from *.default.env."""
    files = get_default_and_override_files(path)
    for (default_file, user_file) in files:
        print("Reading environment variables:")
        print("\tDefaults:  {}".format(default_file))
        print("\tOverrides: {}".format(user_file))
        update_overrides(default_file, user_file)
        print("")

if __name__ == "__main__":
    if any(arg in sys.argv for arg in ['-h', '--help']):
        print("Setup or change required environment variables.")
        print("./setup.py")

    current_dir = dirname(realpath(__file__))
    update_all_overrides(current_dir)
