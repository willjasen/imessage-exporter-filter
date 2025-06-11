#!/bin/bash

BIN="/Users/willjasen/.cargo/bin/imessage-exporter"

# Check if imessage-exporter is installed
if [ ! -f $BIN ]; then
  echo "imessage-exporter not found. Installing..."
  cargo install imessage-exporter
else
  echo "imessage-exporter is already installed. Skipping installation."
fi

# Output wanted messages to HTML
while IFS="," read -r number start_date end_date
do
  echo -e "\n\n\nCreating HTML for $number from $start_date to $end_date\n\n\n"
  mkdir -p "$PWD/$number"

  $BIN -l -c clone -f html -o "$PWD/$number" -s $start_date -e $end_date \
    --conversation-filter $number;

  # Convert HTML to PDF
  # wkhtmltopdf --enable-local-file-access "file://$PWD/$start_date to $end_date/$number.html" "$PWD/$start_d$

done < messages.csv
