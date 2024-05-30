import json
import re
import pyperclip

text = """
Given this existing implementation:
<implementation>
{{IMPLEMENTATION}}
</implementation>

Modify the implementation to satisfy the feature below:
<feature>
{{REQUIREMENTS}}
</feature>

Some minimum requirements you MUST follow:
- Errors must be logged or displayed to the UI.
- If your response mentions a file in the implementation, the file name must follow the framework's convention.
- Only include the modified files in your response.

Remember that the source code of each file in your response must be wrapped in a Markdown code block to be well formatted.

The implementation provided above contains multiple files, each file has the following format:
---<Full file path>---
```<proper language>
Source code
```

Those file paths will be used in the response. Your response must contains multiple parts, each part has the following format as well:
---<Full file path>---
```<proper language>
Source code
```
"""

def convert_to_json(text):
    # Escape backslashes and double quotes
    text = text.replace('\\', '\\\\').replace('"', '\\"')
    
    # Replace newlines with \n
    text = text.replace('\n', '\\n')
    
    # Wrap the entire string in double quotes
    json_string = f'"{text}"'
    
    # Validate the JSON string
    try:
        json.loads(json_string)
    except json.JSONDecodeError as e:
        raise ValueError(f"Invalid JSON string: {e}")
    
    return json_string

json_string = convert_to_json(text)
pyperclip.copy(json_string)
print("Copied to clipboard.")