"""
python script.py --dir_a path\to\A --dir_b path\to\B --workdir path\to\work --app_cmd "bash run_script.sh" --check_expr "exit_code == 0"
"""
import argparse
import random
import os
import shutil
import subprocess
import argparse

def build_and_run(app_cmd, workdir):
    result = subprocess.run(app_cmd, cwd=workdir, shell=True)
    return result.returncode

def copy_partition(file_list, dir_a, dir_b, workdir, partition):
    for f in file_list:
        src = os.path.join(dir_b if f in partition else dir_a, f)
        dst = os.path.join(workdir, f)
        shutil.copy2(src, dst)

def find_failing_files(file_list, dir_a, dir_b, workdir, app_cmd, check_expr):
    if not file_list:
        return []
    copy_partition(file_list, dir_a, dir_b, workdir, file_list)
    exit_code = build_and_run(app_cmd, workdir)
    if eval(check_expr, {"exit_code": exit_code}):
        return []
    if len(file_list) == 1:
        return file_list
    mid = len(file_list) // 2
    return find_failing_files(file_list[:mid], dir_a, dir_b, workdir, app_cmd, check_expr) + \
           find_failing_files(file_list[mid:], dir_a, dir_b, workdir, app_cmd, check_expr)

def main():
    parser = argparse.ArgumentParser(description="Delta debug file changes causing test failures.")
    parser.add_argument("--dir_a", required=True, help="Directory for Set A")
    parser.add_argument("--dir_b", required=True, help="Directory for Set B")
    parser.add_argument("--workdir", required=True, help="Working directory")
    parser.add_argument("--app_cmd", required=True, help="App run script/command")
    parser.add_argument("--check_expr", required=True, help="Python expression to check exit code, e.g. 'exit_code == 0'")
    args = parser.parse_args()

    file_list = sorted(os.listdir(args.dir_a))
    if os.path.exists(args.workdir):
        shutil.rmtree(args.workdir)
    os.makedirs(args.workdir)
    for f in file_list:
        shutil.copy2(os.path.join(args.dir_a, f), os.path.join(args.workdir, f))
    failing_files = find_failing_files(file_list, args.dir_a, args.dir_b, args.workdir, args.app_cmd, args.check_expr)
    print("Failing files:", failing_files)

if __name__ == "__main__":
    main()
