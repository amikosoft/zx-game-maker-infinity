import re
import os

class LanguageManager:
    def __init__(self, file_path):
        self.file_path = file_path
        self.lines = []
        self.entries = [] # List of dicts with 'key', 'value', etc.
        self.load()

    def load(self):
        if not os.path.exists(self.file_path):
            return
        
        with open(self.file_path, 'r', encoding='utf-8') as f:
            self.lines = f.readlines()
        
        self.entries = []
        # Pattern to match: Const KEY as String = "VALUE"
        # Groups: 1: prefix (indent + Const), 2: key, 3: middle (as String = ), 4: value, 5: suffix (comments, etc.)
        pattern = re.compile(r'^(\s*Const\s+)(\w+)(\s+as\s+String\s+=\s+)"(.*)"(\s*.*)$', re.IGNORECASE)
        
        for i, line in enumerate(self.lines):
            match = pattern.match(line.rstrip('\n'))
            if match:
                prefix, key, mid, value, suffix = match.groups()
                self.entries.append({
                    'index': i,
                    'key': key,
                    'value': value,
                    'prefix': prefix,
                    'mid': mid,
                    'suffix': suffix
                })

    def get_entries(self):
        return self.entries

    def update_value(self, key, new_value):
        for entry in self.entries:
            if entry['key'] == key:
                entry['value'] = new_value
                # Update the line in self.lines
                # Preserve the original line ending if possible, or just use \n
                self.lines[entry['index']] = f"{entry['prefix']}{entry['key']}{entry['mid']}\"{new_value}\"{entry['suffix']}\n"
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
