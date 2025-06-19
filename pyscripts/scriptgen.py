import os
import fnmatch
import argparse

def default_runable_script():
    with open ('run.sh', 'w') as rsh:
        rsh.writelines(''' #! /bin/bash
                       echo "EDIT DEFAULT SCRIPT!"\n''')
        print("run.sh generated in current directory!\n")
    os.system("chmod +x run.sh")

def main(command_line=None):
    parser = argparse.ArgumentParser(description='Bash Script Generator.')
    subparsers = parser.add_subparsers(dest='command')
    
    parser_bashgen = subparsers.add_parser('bashgen', help='generate empty bash script')
    parser_bashgen.add_argument('--default', action='store_true', help='Generate Default run script')
    parser_bashgen.set_defaults(func=default_runable_script)
    args = parser.parse_args(command_line)
    if args.command == 'bashgen':
        if args.default:
            args.func()
        else:
            #args.func(**vars(args))
            print(" Un-supported action!\n")
    else:
        parser.print_help()

if __name__ == '__main__':
    main()
