import subprocess
import argparse
import pyperclip

def get_staged_diff(paths):
    """
    Returns the git diff of staged changes for the given paths.
    """
    try:
        # Construct the git diff command with the provided paths
        cmd = ['git', 'diff', '--staged'] + paths
        output = subprocess.check_output(cmd)
        # Decode the output from bytes to string
        diff = output.decode('utf-8')
        return diff
    except subprocess.CalledProcessError as e:
        # Handle any errors that occurred during the git command
        print(f"Error: {e.output.decode('utf-8')}")
        return None

def main():
    parser = argparse.ArgumentParser(description='Get git diff of staged changes for specified paths.')
    parser.add_argument('paths', nargs='+', help='Directories or files to get git diff for')
    args = parser.parse_args()

    staged_diff = get_staged_diff(args.paths)
    if staged_diff:
        try:
            # Copy the diff output to the clipboard
            pyperclip.copy(staged_diff)
            print("Git diff copied to clipboard.")
        except pyperclip.PyperclipException as e:
            print(f"Error copying to clipboard: {e}")
    else:
        print("No staged changes found.")

if __name__ == '__main__':
    main()