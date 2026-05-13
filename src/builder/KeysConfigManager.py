import os
import re

class KeysConfigManager:
    def __init__(self, file_path):
        self.file_path = file_path
        self.lines = []
        self.entries = []  # List of dicts with 'key', 'value', 'line_index'
        self.load()

    def load(self):
        if not os.path.exists(self.file_path):
            return
        
        with open(self.file_path, 'r', encoding='utf-8') as f:
            self.lines = f.readlines()
        
        self.entries = []
        # Pattern to match: key = value; or key = value
        pattern = re.compile(r'^(\s*)(\w+)(\s*=\s*)(.*?)(;?\s*)$')
        
        for i, line in enumerate(self.lines):
            clean_line = line.rstrip('\n')
            match = pattern.match(clean_line)
            if match:
                prefix, key, mid, value, suffix = match.groups()
                # Filter out keys starting with 'controller'
                if not key.lower().startswith('controller'):
                    # Strip quotes from value for editing
                    display_value = value.strip()
                    if (display_value.startswith('"') and display_value.endswith('"')) or \
                       (display_value.startswith("'") and display_value.endswith("'")):
                        display_value = display_value[1:-1]
                    
                    self.entries.append({
                        'line_index': i,
                        'key': key,
                        'value': display_value,
                        'original_value': value, # Includes quotes if any
                        'prefix': prefix,
                        'mid': mid,
                        'suffix': suffix
                    })

    def get_entries(self):
        return self.entries

    def update_value(self, key, new_value):
        for entry in self.entries:
            if entry['key'] == key:
                # If the original value had quotes, wrap the new value in quotes
                original = entry['original_value'].strip()
                if (original.startswith('"') and original.endswith('"')):
                    final_value = f'"{new_value}"'
                elif (original.startswith("'") and original.endswith("'")):
                    final_value = f"'{new_value}'"
                else:
                    final_value = new_value
                
                entry['value'] = new_value
                entry['original_value'] = final_value
                self.lines[entry['line_index']] = f"{entry['prefix']}{entry['key']}{entry['mid']}{final_value}{entry['suffix']}\n"
                return True
        return False

    def save(self):
        try:
            with open(self.file_path, 'w', encoding='utf-8') as f:
                f.writelines(self.lines)
            return True
        except Exception as e:
            print(f"Error saving file {self.file_path}: {e}")
            return False
