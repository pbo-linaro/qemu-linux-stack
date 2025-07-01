import gdb

def current_symbol():
    try:
        name = gdb.selected_frame().name
        if name is None:
            return ''
        else:
            return name()
    except:
            return ''

def current_binary():
    try:
        return gdb.selected_frame().find_sal().symtab.objfile.filename
    except:
        return ''

def current_function():
    try:
        return gdb.selected_frame().name()
    except:
        return ''

def current_callstack():
    res = []
    f = gdb.selected_frame()
    while f:
        name = f.name()
        res.append(name if name else hex(f.pc()))
        f = f.older()
    res.reverse()
    return res

def current_source():
    try:
        return gdb.selected_frame().find_sal().symtab.fullname()
    except:
        return ''

def current_line():
    try:
        return gdb.selected_frame().find_sal().line
    except:
        return ''

def current_arm_world():
    # https://developer.arm.com/documentation/ddi0601/2024-12/AArch64-Registers/SCR-EL3--Secure-Configuration-Register
    # NS: Non-secure bit. This field is used in combination with SCR_EL3.NSE to select the Security state of EL2 and lower Exception levels.
    #
    # https://developer.arm.com/documentation/den0125/latest/Arm-CCA-Extensions
    # The following table shows how the bits control execution and access between the four worlds
    try:
        # register is not available if QEMU does not run with -M virt,secure=on
        scr_el3 = int(gdb.selected_frame().read_register('SCR_EL3'))
    except:
        return None
    ns = scr_el3 >> 0 & 0b1
    nse = scr_el3 >> 62 & 0b1
    match (nse, ns):
        case (0, 0):
            return 'S' # Secure
        case (0, 1):
            return 'NS' # Non Secure
        case (1, 0):
            return 'Root'
        case (1, 1):
            return 'R' # Realm
    return None

def current_arm_exception_level():
    # returned value is a gdb.Value, which supports bitwise operation, but
    # rounds to another value, resulting in a wrong EL. So convert to int.
    cpsr = int(gdb.selected_frame().read_register('cpsr'))
    # bits 3:2 is EL
    el = cpsr >> 2 & 0b11
    if el == 3:
        return 'EL3'
    world = current_arm_world()
    if world is None:
        return 'EL' + str(el)
    return world + '-EL' + str(el)

def current_location():
    return current_source() + ':' + str(current_line())

def step_instruction_until_state_change(state_name, get_state, print_state=True):
    from_state = get_state()
    from_symbol = current_symbol()
    from_location = current_location()
    from_source = current_source()
    last_symbol = from_symbol
    last_location = from_location
    count = 0
    while True:
        gdb.execute('stepi')
        count += 1
        new_state = get_state()
        if new_state and new_state != from_state:
            if print_state:
                print('from_{}: {}'.format(state_name, from_state))
                print('to_{}: {}'.format(state_name, new_state))
                print('from: {} @ {}'.format(from_symbol, from_location))
                print('last: {} @ {}'.format(last_symbol, last_location))
                print('to: {} @ {}'.format(current_symbol(), current_location()))
                print('{} insn executed'.format(count))
            return count
        last_symbol = current_symbol()
        last_location = current_location()

# Single step until we reach a new object file
class next_binary(gdb.Command):
    def __init__(self):
        super(next_binary, self).__init__('next-binary', gdb.COMMAND_USER)

    def invoke(self, argument, fromtty):
        step_instruction_until_state_change('binary', current_binary)

# Single step until function change
class next_function(gdb.Command):
    def __init__(self):
        super(next_function, self).__init__('next-function', gdb.COMMAND_USER)

    def invoke(self, argument, fromtty):
        step_instruction_until_state_change('function', current_function)

# Single step until we reach a new source file
class next_source(gdb.Command):
    def __init__(self):
        super(next_source, self).__init__('next-source', gdb.COMMAND_USER)

    def invoke(self, argument, fromtty):
        step_instruction_until_state_change('source', current_source)

# Single step until exception level change
class next_arm_exception_level(gdb.Command):
    def __init__(self):
        super(next_arm_exception_level, self).__init__('next-arm-exception-level', gdb.COMMAND_USER)

    def invoke(self, argument, fromtty):
        step_instruction_until_state_change('EL', current_arm_exception_level)

# Print current exception level
class arm_exception_level(gdb.Command):
    def __init__ (self):
        super (arm_exception_level, self).__init__ ("arm-exception-level", gdb.COMMAND_USER)

    def invoke (self, arg, from_tty):
        print(current_arm_exception_level())

# Print callstack
class callstack(gdb.Command):
    def __init__ (self):
        super (callstack, self).__init__ ("callstack", gdb.COMMAND_USER)

    def invoke (self, arg, from_tty):
        print(current_callstack())

# Single step until callstack change
class next_callstack(gdb.Command):
    def __init__(self):
        super(next_callstack, self).__init__('next-callstack', gdb.COMMAND_USER)

    def invoke(self, argument, fromtty):
        step_instruction_until_state_change('callstack', current_callstack)

arm_exception_level()
callstack()
next_arm_exception_level()
next_binary()
next_callstack()
next_function()
next_source()
