import os
import argparse
import pyperclip

def concat_files(paths):
    result = ""

    for path in paths:
        if os.path.isfile(path):
            file_name = os.path.basename(path)
            with open(path, "r") as f:
                file_content = f.read()
            result += f"---{file_name}---\n```dart\n{file_content}\n```\n\n"
        elif os.path.isdir(path):
            for root, _, files in os.walk(path):
                for file in files:
                    file_path = os.path.join(root, file)
                    file_name = os.path.basename(file_path)
                    with open(file_path, "r") as f:
                        file_content = f.read()
                    result += f"---{file_name}---\n```dart\n{file_content}\n```\n\n"

    return result

def write_to_file(text, output_file):
    with open(output_file, "w", encoding="utf-8") as f:
        f.write(text)
    print(f"Concatenated content written to {output_file}")

def copy_to_clipboard(text):
    pyperclip.copy(text)
    print("Concatenated content copied to clipboard.")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Concatenate files with a specific format")
    parser.add_argument("paths", nargs="+", help="Path(s) to file(s) or directory(ies) containing the files")
    output_group = parser.add_mutually_exclusive_group()
    output_group.add_argument("-o", "--output", help="Output file path")
    output_group.add_argument("-c", "--clipboard", action="store_true", help="Copy output to clipboard")
    args = parser.parse_args()

    concatenated_content = concat_files(args.paths)

    if args.output:
        write_to_file(concatenated_content, args.output)
    elif args.clipboard:
        copy_to_clipboard(concatenated_content)
    else:
        print("No output option specified. Use -o/--output or -c/--clipboard.")