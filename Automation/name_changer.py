# name_changer.py - Create a .py script that navigates through files in a directory and rename
# all files with all capital letters.
# The script shall create the following folder/file structure.
# It will replace with capital letters (only first and last letter of name),
# only folders/ directories and files with no extension.

import os


def create_directory_structure():
    main_dir = "main"
    head_dir = "head"
    commit_dir = "commit"
    dev_dir = "dev"
    opt_dir = "opt"
    systemd_file = "systemd.d"
    commit_fix_dir = "commit_fix"
    src_dir = "src"
    commit_fix_fix_file = "commit_fix_fix"
    app_main_file = "app_main"
    variables_file = "variables.txt"
    unit_test_file = "unit_test.py"

    os.makedirs(main_dir, exist_ok=True)

    os.makedirs(os.path.join(main_dir, head_dir), exist_ok=True)

    os.makedirs(os.path.join(main_dir, commit_dir), exist_ok=True)

    os.makedirs(os.path.join(main_dir, head_dir, dev_dir), exist_ok=True)

    os.makedirs(os.path.join(main_dir, head_dir, opt_dir), exist_ok=True)

    with open(os.path.join(main_dir, head_dir, dev_dir, systemd_file), "w") as f:
        pass  # Empty file

    os.makedirs(os.path.join(main_dir, commit_dir, commit_fix_dir), exist_ok=True)

    os.makedirs(os.path.join(main_dir, commit_dir, commit_fix_dir, src_dir), exist_ok=True)

    with open(os.path.join(main_dir, commit_dir, commit_fix_dir, src_dir, app_main_file), "w") as f:
        pass  # Empty file

    with open(os.path.join(main_dir, commit_dir, commit_fix_dir, commit_fix_fix_file), "w") as f:
        pass  # Empty file

    with open(os.path.join(main_dir, commit_dir, variables_file), "w") as f:
        pass  # Empty file

    with open(os.path.join(main_dir, commit_dir, commit_fix_dir, src_dir, unit_test_file), "w") as f:
        pass  # Empty file


if __name__ == "__main__":
    create_directory_structure()
