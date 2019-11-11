#!usr/bin/python

"""Convert from ld65 debug info into to FCEUX's NameList.

The name list is written out to separate files per bank.

Assumptions:
    * Fixed bank lives in last bank
    * Fixed bank is named `PRG`
    * Zeropage bank is named `ZP`
    * Banked segments have bank id in name. Example: `BANK_00`
    * Only RAM memory area as address 0 is `ZP`
    * Must run this script from the root of fogcity project dir.

Name list documentation:
    http://www.fceux.com/web/help/fceux.html?Debugger.html > '.nl files format'

Example:
    python ./tools/namelist_converter.py -n fog_city -d build/fog_city.debug
        -c cfg/mmc5.cfg -o build`

"""

import re
import os
import argparse


# Shared Constants
NL_FILE_NAME = '%s.nes.%s.nl'
FIXED_BANK_INDEX = 0x3F
# RAM isn't actually banked, but needs its own name list file.
RAM_BANK_INDEX = 0x40
COMMENT_STR = '#'
HEX_BASE = 16


def get_fixed_bank_segments(linker_script_file):
    """Create list of segments that are allocated in the fixed bank.

    Args:
        linker_script_file (file obj): Open file pointer to the linker script.

    Returns:
        fixed_bank_segments (list): List of strings of segment names.

    """
    FIXED_BANK_STR = 'load = PRG,'
    linker_script_file.seek(0)
    fixed_bank_segments = []

    for line in linker_script_file:
        # Remove leading white space characters
        line = line.lstrip()
        if FIXED_BANK_STR in line and not line.startswith(COMMENT_STR):
            line = line.split(':')
            fixed_bank_segments.append(line[0])

    return fixed_bank_segments


def get_ram_memory_areas(linker_script_file):
    """Parses linker script for all memory areas that live in RAM.

    Args:
        linker_script_file (file obj): Open file pointer to the linker script.

    Returns:
        ram_memory_areas (list): List of strings of RAM memory area names.

    """
    CPU_RAM_ADDR_END = 0x7FF
    MEM_AREA_REGEX = '([\w]+): start = \$([\w]+),'
    ZP_SEGMENT_NAME = 'ZP'
    ram_memory_areas = []

    linker_script_file.seek(0)
    mem_area_pattern = re.compile(MEM_AREA_REGEX)

    for line in linker_script_file:
        # Check if line is a comment. Ignore if so.
        # Remove leading white space characters
        line = line.lstrip()
        if line.startswith(COMMENT_STR):
            continue

        match = mem_area_pattern.match(line)
        if match:
            (mem_area_name, mem_area_start) = match.groups()
            start_addr = int(mem_area_start, HEX_BASE)
            # Check if memory area's starting address is in RAM.
            # ZP's starting address is 0. Ignore all other memory areas with
            # starting address of 0.
            if ((start_addr <= CPU_RAM_ADDR_END) and
               ((start_addr != 0) or (mem_area_name == ZP_SEGMENT_NAME))):
                ram_memory_areas.append(mem_area_name)

    return ram_memory_areas


def get_ram_segments(linker_script_file):
    """Parses linker script for all segments that live in RAM.

    Args:
        linker_script_file (file obj): Open file pointer to the linker script.

    Returns:
        ram_segments (list): List of strings of RAM segment names.

    """
    ram_memory_areas = get_ram_memory_areas(linker_script_file)
    linker_script_file.seek(0)

    RAM_LOAD_STR = 'load = %s,'
    ram_load_str_list = [RAM_LOAD_STR % i for i in ram_memory_areas]
    ram_segments = []

    for line in linker_script_file:
        # Remove leading white space characters
        line = line.lstrip()
        # Ignore comments
        if line.startswith(COMMENT_STR):
            continue

        if any(load_str in line for load_str in ram_load_str_list):
            line = line.split(':')
            ram_segments.append(line[0])

    return ram_segments


def map_seg_id_to_bank_id(debug_file, fixed_bank_segments, ram_segments):
    """Generate map of segment ID to bank ID.

    FCEUX assumes bank sizes are $4000, while mine are $2000. This means
    I will have to divide my bank id's by 2.

    From FCEUX's documentation:
        bb - 16k iNES bank, designates which 16k bank from the iNES file is
        mapped here. Note that the number may be not the same as the actual
        hardware bank of the mapper.

    Args:
        debug_file (file obj): Open file pointer to the ld65 debug info file.
        fixed_bank_segments (list): List of strings of segment names.
        ram_segments (list): List of strings of RAM segment names.

    Returns:
        seg_id_to_bank_id (map): map from str of seg ID to int of bank ID

    """
    SEG_REGEX = 'seg\tid=([\d]+),name="([\w]+)"'
    seg_pattern = re.compile(SEG_REGEX)
    seg_id_to_bank_id = {}

    for line in debug_file:
        match = seg_pattern.match(line)
        if match:
            (seg_id, seg_name) = match.groups()
            if seg_name in fixed_bank_segments:
                seg_id_to_bank_id[seg_id] = FIXED_BANK_INDEX
                continue
            elif seg_name in ram_segments:
                seg_id_to_bank_id[seg_id] = RAM_BANK_INDEX
                continue
            elif 'BANK_' in seg_name:
                seg_name = seg_name.split('_')
                seg_id_to_bank_id[seg_id] = int(seg_name[1], HEX_BASE) / 2
                continue

    return seg_id_to_bank_id


def generate_name_list(debug_file, seg_id_to_bank_id):
    """Parse through the ld65 debug file for symbols.

    Only matches the symbols in cartridge RAM and ROM.
    Creates list of symbols per bank. List conforms to FCEUX's debug file
    format. See link for documentation.

        http://www.fceux.com/web/help/fceux.html?Debugger.html

    Args:
        debug_file (file obj): Open file pointer to the ld65 debug info file.
        seg_id_to_bank_id (map): map from str of seg ID to int of bank ID

    Returns:
        bank_id_to_name_list (dict): Dict of int bank id to str name list.

    """
    SYM_ID_NAME_REGEX = 'sym\tid=([\d]+),name="([\w]+)"'
    SEG_ID_REGEX = 'val=0x([0-9A-F]+),seg=([\d]+)'
    NL_FORMAT = '$%04X#%s#\n'

    sym_pattern = re.compile(SYM_ID_NAME_REGEX)
    seg_pattern = re.compile(SEG_ID_REGEX)
    bank_id_to_name_list = {}
    debug_file.seek(0)

    for line in debug_file:
        sym_match = sym_pattern.match(line)
        seg_match = seg_pattern.search(line)

        if sym_match and seg_match:
            (sym_id, sym_name) = sym_match.groups()
            (sym_addr, seg_id) = seg_match.groups()
            bank_id = seg_id_to_bank_id[seg_id]
            name_list = bank_id_to_name_list.get(bank_id, '')
            name_list += NL_FORMAT % (int(sym_addr, HEX_BASE), sym_name)
            bank_id_to_name_list[bank_id] = name_list

    return bank_id_to_name_list


def print_name_lists(bank_id_to_name_list):
    for bank_id in bank_id_to_name_list:
        print bank_id
        for line in bank_id_to_name_list[bank_id].split('\n'):
            print '\t%s' % line


def create_nl_files(args, bank_id_to_name_list):
    """Creates name list files and populates with appropriate data.

    If file already exists, file contents are overwritten.

    Args:
        args (argparser): Command line arguments
        bank_id_to_name_list (dict): Dict of int bank id to str name list.

    """
    for bank_id in bank_id_to_name_list:
        bank_str = 'ram' if (bank_id == RAM_BANK_INDEX) else ('%x' % bank_id)
        file_path = os.path.join(args.nl_output_dir,
                                 NL_FILE_NAME % (args.rom_name, bank_str))
        file = open(file_path, 'w+')
        file.write(bank_id_to_name_list[bank_id])
        file.close()


def main():
    parser = argparse.ArgumentParser(description='Debug Name List Generator')
    parser.add_argument('-n', action='store', dest='rom_name', type=str,
                        required=True, help='Game name')
    parser.add_argument('-d', action='store', dest='debug_file', type=str,
                        required=True, help='ld65 debug file path')
    parser.add_argument('-c', action='store', dest='linker_script_file',
                        type=str, required=True, help='ld65 config file path')
    parser.add_argument('-o', action='store', dest='nl_output_dir',
                        type=str, required=True, help='Output dir to put name \
                        list files in')
    args = parser.parse_args()

    debug_file = None
    linker_script_file = None

    try:
        debug_file = open(args.debug_file, 'rt')
        linker_script_file = open(args.linker_script_file, "rt")
    except IOError:
        print('Error on opening a file.')
        raise

    fixed_bank_segments = get_fixed_bank_segments(linker_script_file)
    ram_segments = get_ram_segments(linker_script_file)
    linker_script_file.close()

    seg_id_to_bank_id = map_seg_id_to_bank_id(debug_file,
                                              fixed_bank_segments,
                                              ram_segments)
    bank_id_to_name_list = generate_name_list(debug_file,
                                              seg_id_to_bank_id)
    debug_file.close()

    # print_name_lists(bank_id_to_name_list)
    create_nl_files(args, bank_id_to_name_list)


if __name__ == '__main__':
    main()
