import json
import argparse
import sys
"""
Config.json
{
    "key": "a:id -> b:id",
    "fields": [
        "a:name",
        "a:age",
        "b:email",
        "b:address"
    ]
}
a.json
[
    {"id": 1, "name": "Alice", "age": 30},
    {"id": 2, "name": "Bob", "age": 25},
    {"id": 3, "name": "Charlie", "age": 35}
]
b.json
[
    {"id": 1, "email": "alice@example.com", "address": "123 Main St"},
    {"id": 2, "email": "bob@example.com", "address": "456 Elm St"},
    {"id": 3, "email": "charlie@example.com", "address": "789 Oak St"}
]
python merge_json.py a.json b.json config.json final.json

"""
def load_json(file_path):
    try:
        with open(file_path, 'r') as file:
            return json.load(file)
    except FileNotFoundError:
        print(f"Error: The file '{file_path}' was not found.")
        sys.exit(1)
    except json.JSONDecodeError:
        print(f"Error: The file '{file_path}' is not a valid JSON file.")
        sys.exit(1)

def save_json(data, file_path):
    try:
        with open(file_path, 'w') as file:
            json.dump(data, file, indent=4)
    except IOError as e:
        print(f"Error: Could not write to file '{file_path}'. {e}")
        sys.exit(1)

def parse_config(config):
    try:
        key_mapping = config['key'].split('->')
        a_key = key_mapping[0].strip()
        b_key = key_mapping[1].strip()

        a_fields = [field.split(':')[1].strip() for field in config['fields'] if field.startswith('a:')]
        b_fields = [field.split(':')[1].strip() for field in config['fields'] if field.startswith('b:')]

        return a_key, b_key, a_fields, b_fields
    except KeyError as e:
        print(f"Error: Missing expected key in config: {e}")
        sys.exit(1)

def merge_json(a_data, b_data, a_key, b_key, a_fields, b_fields):
    try:
        b_dict = {item[b_key]: item for item in b_data}

        final_data = []
        for a_item in a_data:
            a_key_value = a_item[a_key]
            if a_key_value in b_dict:
                b_item = b_dict[a_key_value]
                merged_item = {}

                # Merge fields from a.json
                for field in a_fields:
                    if field in a_item:
                        merged_item[field] = a_item[field]

                # Merge fields from b.json with type checking
                for field in b_fields:
                    if field in b_item:
                        if field in merged_item:
                            # Check if types match
                            if type(merged_item[field]) != type(b_item[field]):
                                print(f"Warning: Type mismatch for field '{field}' with key '{a_key_value}'. Skipping this field.")
                                continue
                        merged_item[field] = b_item[field]

                final_data.append(merged_item)

        return final_data
    except KeyError as e:
        print(f"Error: Missing expected key in data: {e}")
        sys.exit(1)

def main():
    parser = argparse.ArgumentParser(description='Merge two JSON files based on a configuration.')
    parser.add_argument('a_json', help='Path to the first JSON file (a.json)')
    parser.add_argument('b_json', help='Path to the second JSON file (b.json)')
    parser.add_argument('config_json', help='Path to the configuration JSON file')
    parser.add_argument('output_json', help='Path to the output JSON file (final.json)')

    args = parser.parse_args()

    # Load JSON data
    a_data = load_json(args.a_json)
    b_data = load_json(args.b_json)

    # Load and parse config
    config = load_json(args.config_json)
    a_key, b_key, a_fields, b_fields = parse_config(config)

    # Merge JSON data
    final_data = merge_json(a_data, b_data, a_key, b_key, a_fields, b_fields)

    # Save the final merged JSON
    save_json(final_data, args.output_json)

if __name__ == '__main__':
    main()
