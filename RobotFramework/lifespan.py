logcat_file_path = 'logcat_applications.txt'  # Define the file path to the logcat file


def parse_logcat(logcat_file):
    app_lifespans = {}  # Dictionary to store application lifespans

    with open(logcat_file, 'r') as file:
        for line in file:
            if 'ActivityTaskManager: START u0' in line:
                # Extract application name and start time
                parts = line.split()
                if 'cmp=' in parts:
                    cmp_index = parts.index('cmp=')
                    if cmp_index + 1 < len(parts):
                        app_name = parts[cmp_index + 1].split('/')[0]  # Extracting package name
                        start_time = parts[0]  # Assuming start time is at the beginning of the line
                        app_lifespans[app_name] = {'start_time': start_time}
            elif 'Layer: Destroyed ActivityRecord' in line:
                # Extract application name and stop time
                parts = line.split()
                if 'Destroy' in parts:
                    destroy_index = parts.index('Destroy')
                    if destroy_index + 2 < len(parts):
                        app_name = parts[destroy_index + 2].split('/')[0]  # Extracting package name
                        stop_time = parts[0]  # Assuming stop time is at the beginning of the line
                        # If the application name already exists (meaning it started), record stop time
                        if app_name in app_lifespans:
                            app_lifespans[app_name]['stop_time'] = stop_time

    return app_lifespans

# Usage example


parsed_data = parse_logcat(logcat_file_path)
print(parsed_data)
