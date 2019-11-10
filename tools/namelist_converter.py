#!usr/bin/python

"""Convert from ld65 debug info into to FCEUX's NameList.

The name list is written out to separate files per bank.

Name list documentation:
    http://www.fceux.com/web/help/fceux.html?Debugger.html
"""

import re


# Customize me!
ROM_NAME = 'fog_city'
DEBUG_FILE_NAME = './build/fog_city.debug'
LINKER_SCRIPT_FILE_NAME = './cfg/mmc5.cfg'

# Constants
NL_FILE_NAME = '%s.nes.%x.nl'
FIXED_BANK_INDEX = 0x7F
# RAM isn't actually banked.
RAM_BANK_INDEX = 0x80
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

        # Groups consists of (Memory area name, memory area start address)
        match = mem_area_pattern.match(line)
        if match:
            groups = match.groups()
            start_addr = int(groups[1], HEX_BASE)
            # Check if memory area's starting address is in RAM.
            # ZP's starting address is 0. Ignore all other memory areas with
            # starting address of 0.
            if ((start_addr <= CPU_RAM_ADDR_END) and
               ((start_addr != 0) or (groups[0] == ZP_SEGMENT_NAME))):
                ram_memory_areas.append(groups[0])

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
                seg_id_to_bank_id[seg_id] = int(seg_name[1], HEX_BASE)
                continue

    return seg_id_to_bank_id


def generate_symbol_list(debug_file, seg_to_bank_id):
    """
    """
    pass


def create_nl_files(bank_id_to_symbol_list):
    """
    """
    pass


def main():
    debug_file = None
    linker_script_file = None

    try:
        debug_file = open(DEBUG_FILE_NAME, 'rt')
        linker_script_file = open(LINKER_SCRIPT_FILE_NAME, "rt")
    except IOError:
        print('Error on opening a file.')
        raise

    fixed_bank_segments = get_fixed_bank_segments(linker_script_file)
    ram_segments = get_ram_segments(linker_script_file)
    linker_script_file.close()

    seg_id_to_bank_id = map_seg_id_to_bank_id(debug_file,
                                              fixed_bank_segments,
                                              ram_segments)
    bank_id_to_symbol_list = generate_symbol_list(debug_file,
                                                  seg_id_to_bank_id)
    debug_file.close()

    create_nl_files(bank_id_to_symbol_list)


if __name__ == '__main__':
    main()
