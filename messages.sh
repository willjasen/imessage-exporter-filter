#!/bin/bash

#echo -E "\n\n\nDELETING PREVIOUS DATA!!!\n\n\n"
#find "$PWD" -type d -name '*' -delete

# Output wanted messages to HTML
while IFS="," read -r number start_date end_date
do
  echo -e "\n\n\nCreating HTML to $number from $start_date to $end_date\n\n\n"
  mkdir "$PWD/$start_date to $end_date"
  imessage-exporter -l -c compatible -f html -o "$PWD/$start_date to $end_date" -s $start_date -e $end_date
  #sleep 5
  find "$PWD/$start_date to $end_date" -type f -maxdepth 1 -not -name "$number.html" -delete

  # Convert HTML to PDF
  wkhtmltopdf --enable-local-file-access "file://$PWD/$start_date to $end_date/$number.html" "$PWD/$start_d$

done < messages.csv
