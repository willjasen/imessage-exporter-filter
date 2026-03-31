#!/bin/bash

BIN=$(jq -r '.BIN' data.json)
OUTPUT_DIR=$(jq -r '.OUTPUT_DIR' data.json)

# Check if imessage-exporter is installed
if [ ! -f $BIN ]; then
  echo "imessage-exporter not found. Installing..."
  cargo install imessage-exporter
else
  echo "imessage-exporter is already installed. Skipping installation."
fi

# Export all messages (no filtering)
export_all() {
  # Export all as HTML
  echo -e "\n\n\nCreating HTML for all messages\n\n\n"
  mkdir -p "$OUTPUT_DIR/HTML/all"
  $BIN -l -c clone -f html --ignore-disk-warning -o "$OUTPUT_DIR/HTML/all"

  # Export all as TXT
  echo -e "\n\n\nExporting all messages to TXT\n\n\n"
  mkdir -p "$OUTPUT_DIR/TXT/all"
  $BIN \
    --no-lazy \
    --ignore-disk-warning \
    --format txt \
    --export-path "$OUTPUT_DIR/TXT/all" \
    --copy-method clone
}

# Export filtered messages from CSV
export_filtered() {
while IFS="," read -r number start_date end_date
do

  # Export as HTML
  echo -e "\n\n\nCreating HTML for $number from $start_date to $end_date\n\n\n"
  mkdir -p "$OUTPUT_DIR/HTML/$number"
  $BIN -l -c clone -f html --ignore-disk-warning -o "$OUTPUT_DIR/HTML/$number" -s $start_date -e $end_date \
    --conversation-filter $number;

  # Export as TXT
  echo -e "\n\n\nExporting messages for $number to TXT\n\n\n"
  mkdir -p "$OUTPUT_DIR/TXT/$number"
  $BIN \
    --no-lazy \
    --ignore-disk-warning \
    --format txt \
    --export-path "$OUTPUT_DIR/TXT/$number" \
    --copy-method clone \
    --conversation-filter $number;

  # Convert HTML to PDF
  mkdir -p "$OUTPUT_DIR/PDF"
  wkhtmltopdf --enable-local-file-access "file://$OUTPUT_DIR/HTML/$number/$number.html" "$OUTPUT_DIR/PDF/$number.pdf"

done < messages.csv
}

# Argument handling
if [[ "$1" == "--all" ]]; then
  export_all
elif [[ "$1" == "--filtered" ]]; then
  export_filtered
else
  echo "Usage: $0 --all | --filtered"
  exit 1
fi

