#!/usr/bin/env bash

EXPORTER_URL="https://example.social/api/v1/akkoma/metrics"  # Replace with your exporter URL
CREDENTIALS="Admin:Admin" # Replace with your Admin credentials

# Make a request to the exporter and store the response in a variable
RESPONSE=$(curl -s -u $CREDENTIALS "$EXPORTER_URL")

# Check if the request was successful
if [ $? -eq 0 ]; then
  # Define a function to print a CheckMK service
  print_checkmk_service() {
    local service_name="$1"
    local metric_value="$2"
    echo "0 $service_name $service_name=$metric_value"
  }

  # Loop through each line in the response
  while IFS= read -r line; do
    # Check if the line starts with one of the desired metric prefixes
    if [[ "$line" =~ ^pleroma_remote_users_total|^pleroma_local_statuses_total|^pleroma_domains_total|^pleroma_local_users_total ]]; then
      # Extract the metric name and value
      metric_name=$(echo "$line" | awk '{print $1}')
      metric_value=$(echo "$line" | awk '{print $2}')

      # Print the metric in CheckMK format
      print_checkmk_service "$metric_name" "$metric_value"
    fi
  done <<< "$RESPONSE"
else
  echo "Failed to fetch data from the exporter."
fi