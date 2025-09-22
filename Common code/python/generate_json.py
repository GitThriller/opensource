import json
import os

def get_input(prompt):
    response = input(prompt)
    return response if response else None

def get_list_input(prompt):
    items = []
    while True:
        item = input(prompt + " (or press Enter to finish): ")
        if item:
            items.append(item)
        else:
            break
    return items

def create_package_parameter():
    print("\nEnter details for a new package parameter:")
    parameter = {
        "name": get_input("Parameter name: "),
        "data_type": get_input("Data type: "),
        "default_value": get_input("Default value: "),
        "min": get_input("Min value (or press Enter to skip): "),
        "max": get_input("Max value (or press Enter to skip): "),
        "options": get_list_input("Option")
    }
    parameter["meta"] = {
        "description": get_input("Meta description: "),
        "display_name": get_input("Meta display name: "),
        "display_order": int(get_input("Meta display order: "))
    }
    return parameter

def create_table_columns():
    columns = []
    while True:
        print("\nEnter details for a new column (or press Enter to finish):")
        name = get_input("Column name: ")
        if not name:
            break
        column = {
            "name": name,
            "data_type": get_input("Data type: "),
            "length": int(get_input("Length: ")) if get_input("Length: ") else None,
            "is_identity": get_input("Is identity (true/false): ").lower() == "true",
            "is_unique": get_input("Is unique (true/false): ").lower() == "true",
            "position": int(get_input("Position: ")),
            "default_value": get_input("Default value: "),
            "meta": {
                "display_name": get_input("Meta display name: "),
                "description": get_input("Meta description: ")
            }
        }
        columns.append(column)
    return columns

def create_input_table():
    print("\nEnter details for a new input table:")
    table = {
        "schema": get_input("Schema: "),
        "name": get_input("Table name: "),
        "meta": {
            "display_name": get_input("Meta display name: "),
            "description": get_input("Meta description: ")
        },
        "columns": create_table_columns()
    }
    return table

def create_output_table():
    print("\nEnter details for a new output table:")
    table = {
        "name": get_input("Table name: "),
        "schema": get_input("Schema: "),
        "meta": {
            "display_name": get_input("Meta display name: ")
        },
        "columns": create_table_columns()
    }
    return table

def create_step():
    print("\nEnter details for a new step:")
    step = {
        "name": get_input("Step name: "),
        "type": get_input("Step type: "),
        "code": get_input("Step code: "),
        "parameters": get_list_input("Step parameter name")
    }
    step["order"] = int(get_input("Step order: "))
    return step

def create_validation():
    print("\nEnter details for a new validation:")
    validation = {
        "name": get_input("Validation name: "),
        "type": get_input("Validation type: "),
        "condition": get_input("Validation condition: "),
        "message": get_input("Validation message: ")
    }
    return validation

def create_analysis():
    print("\nEnter details for a new analysis:")
    analysis = {
        "name": get_input("Analysis name: "),
        "meta": {
            "display_name": get_input("Analysis meta display name: "),
            "description": get_input("Analysis meta description: ")
        },
        "steps": get_list_input("Analysis step name"),
        "analysis_parameters": [],
        "input_tables": []
    }

    print("\nEnter details for analysis input tables:")
    while True:
        add_table = get_input("Would you like to add an input table to the analysis? (yes/no): ").lower()
        if add_table == "yes":
            analysis["input_tables"].append(create_table_columns())
        else:
            break

    analysis["output_tables"] = get_list_input("Analysis output table name")
    analysis["report"] = {
        "heights_pixels": int(get_input("Report height pixels: ")),
        "type": get_input("Report type: "),
        "url": get_input("Report URL: "),
        "width_pixels": int(get_input("Report width pixels: "))
    }
    return analysis

def create_action():
    print("\nEnter details for a new action:")
    action = {
        "analysis_name": get_input("Action analysis name: "),
        "name": get_input("Action name: "),
        "scope": get_input("Action scope: "),
        "meta": {
            "display_name": get_input("Action meta display name: ")
        },
        "aggregates": [],
        "data_levels": []
    }
    while True:
        add_aggregate = get_input("Would you like to add an aggregate to the action? (yes/no): ").lower()
        if add_aggregate == "yes":
            aggregate = {
                "aggregation": get_input("Aggregate aggregation: "),
                "filters": [],
                "label_name": get_input("Aggregate label name: "),
                "meta": {
                    "display_name": get_input("Aggregate meta display name: "),
                    "primary": get_input("Is primary (true/false): ").lower() == "true",
                    "summary_string": get_input("Aggregate summary string: ")
                }
            }
            while True:
                add_filter = get_input("Would you like to add a filter to the aggregate? (yes/no): ").lower()
                if add_filter == "yes":
                    filter_ = {
                        "label_name": get_input("Filter label name: "),
                        "value": get_input("Filter value: ")
                    }
                    aggregate["filters"].append(filter_)
                else:
                    break
            action["aggregates"].append(aggregate)
        else:
            break

    while True:
        add_data_level = get_input("Would you like to add a data level to the action? (yes/no): ").lower()
        if add_data_level == "yes":
            data_level = {
                "table_mapping": {
                    "exp_table": get_input("Exp table name: "),
                    "act_table": get_input("Act table name: "),
                    "key_columns": get_list_input("Key column name"),
                    "display_columns": get_list_input("Display column name"),
                    "display_detail_columns": get_list_input("Display detail column name")
                },
                "summary_statement": get_input("Data level summary statement: "),
                "allow_comments": get_input("Allow comments (true/false): ").lower() == "true",
                "allow_attachments": get_input("Allow attachments (true/false): ").lower() == "true",
                "assignable": get_input("Assignable (true/false): ").lower() == "true",
                "default_sort": {
                    "column": get_input("Default sort column: "),
                    "ascending": get_input("Default sort ascending (true/false): ").lower() == "true"
                },
                "labels": []
            }
            while True:
                add_label = get_input("Would you like to add a label to the data level? (yes/no): ").lower()
                if add_label == "yes":
                    label = {
                        "name": get_input("Label name: "),
                        "data_type": get_input("Label data type: "),
                        "default_value": get_input("Label default value: "),
                        "meta": {
                            "description": get_input("Label meta description: "),
                            "display_name": get_input("Label meta display name: "),
                            "display_order": int(get_input("Label display order: ")),
                            "is_outcome": get_input("Is outcome (true/false): ").lower() == "true",
                            "group": get_input("Label group: "),
                            "placeholder": get_input("Label placeholder: ")
                        },
                        "options": get_list_input("Label option"),
                        "min": get_input("Label min value: "),
                        "max": get_input("Label max value: "),
                        "currency": get_input("Label currency: "),
                        "dependencies": get_list_input("Label dependency"),
                        "is_required": get_input("Is required (true/false): ").lower() == "true"
                    }
                    data_level["labels"].append(label)
                else:
                    break
            action["data_levels"].append(data_level)
        else:
            break

    return action

def create_download():
    print("\nEnter details for a new download:")
    download = {
        "display_name": get_input("Download display name: "),
        "files": [{
            "filename": get_input("File name: "),
            "type": get_input("File type: "),
            "view": get_input("File view: ")
        }],
        "name": get_input("Download name: "),
        "templates": []
    }

    while True:
        add_template = get_input("Would you like to add a template to the download? (yes/no): ").lower()
        if add_template == "yes":
            template = {
                "repeated_views": [],
                "static_view": get_input("Template static view: "),
                "template_name": get_input("Template name: "),
                "type": get_input("Template type: ")
            }
            while True:
                add_repeated_view = get_input("Would you like to add a repeated view to the template? (yes/no): ").lower()
                if add_repeated_view == "yes":
                    repeated_view = {
                        "anchor": get_input("Repeated view anchor: "),
                        "view": get_input("Repeated view: ")
                    }
                    template["repeated_views"].append(repeated_view)
                else:
                    break
            download["templates"].append(template)
        else:
            break

    return download

def main():
    data = {
        "name": get_input("Name: "),
        "version": int(get_input("Version: ")),
        "meta": {
            "display_name": get_input("Meta display name: "),
            "tagline": get_input("Meta tagline: "),
            "short_description": get_input("Meta short description: "),
            "description": get_input("Meta description: "),
            "tags": get_list_input("Meta tag"),
            "color": get_input("Meta color: "),
            "featured_analyses": get_list_input("Featured analyses"),
            "additional_features": {
                "has_support_file_uploader": get_input("Has support file uploader (true/false): ").lower() == "true",
                "support_file_uploader_description": get_input("Support file uploader description: "),
                "support_file_formats": get_input("Support file formats: "),
                "support_file_tags": get_list_input("Support file tag")
            }
        },
        "collection": get_input("Collection: "),
        "package_parameters": []
    }

    while True:
        add_parameter = get_input("\nWould you like to add a package parameter? (yes/no): ").lower()
        if add_parameter == "yes":
            data["package_parameters"].append(create_package_parameter())
        else:
            break

    data["input_tables"] = []
    while True:
        add_table = get_input("\nWould you like to add an input table? (yes/no): ").lower()
        if add_table == "yes":
            data["input_tables"].append(create_input_table())
        else:
            break

    data["output_tables"] = []
    while True:
        add_table = get_input("\nWould you like to add an output table? (yes/no): ").lower()
        if add_table == "yes":
            data["output_tables"].append(create_output_table())
        else:
            break

    data["steps"] = []
    while True:
        add_step = get_input("\nWould you like to add a step? (yes/no): ").lower()
        if add_step == "yes":
            data["steps"].append(create_step())
        else:
            break

    data["validations"] = []
    while True:
        add_validation = get_input("\nWould you like to add a validation? (yes/no): ").lower()
        if add_validation == "yes":
            data["validations"].append(create_validation())
        else:
            break

    data["analyses"] = []
    while True:
        add_analysis = get_input("\nWould you like to add an analysis? (yes/no): ").lower()
        if add_analysis == "yes":
            data["analyses"].append(create_analysis())
        else:
            break

    data["actions"] = []
    while True:
        add_action = get_input("\nWould you like to add an action? (yes/no): ").lower()
        if add_action == "yes":
            data["actions"].append(create_action())
        else:
            break

    data["downloads"] = []
    while True:
        add_download = get_input("\nWould you like to add a download? (yes/no): ").lower()
        if add_download == "yes":
            data["downloads"].append(create_download())
        else:
            break

    data["options"] = {
        "null_empty_strings": get_input("Options: null_empty_strings (true/false): ").lower() == "true"
    }

    data["regression_tests"] = []
    while True:
        add_test = get_input("\nWould you like to add a regression test? (yes/no): ").lower()
        if add_test == "yes":
            test = {
                "test_name": get_input("Test name: "),
                "description": get_input("Test description: "),
                "steps": get_list_input("Test step name")
            }
            data["regression_tests"].append(test)
        else:
            break

    # Convert the dictionary to a JSON string with pretty formatting
    json_data = json.dumps(data, indent=4)

    # Define the output file path
    output_path = r""

    # Ensure the directory exists
    os.makedirs(os.path.dirname(output_path), exist_ok=True)

    # Write the JSON string to the file
    with open(output_path, "w") as json_file:
        json_file.write(json_data)

    print(f"\nJSON file has been generated successfully and saved to {output_path}")

if __name__ == "__main__":
    main()
