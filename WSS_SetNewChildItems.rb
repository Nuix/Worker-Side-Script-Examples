=begin

Copyright 2021 Nuix
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

Visit GitHub for more examples: https://github.com/Nuix/Worker-Side-Script-Examples

=end

# Full path to a CSV file that contains 2 columns (with headers):
# - GUID of parent item already in the case in first column
# - Path to a file to be added as a child in the second column
# Multiple rows in the CSV can point to the same parent GUID
$xref_csv_file = "D:\\Temp\\ChildItemXref.csv"

$xref_data = Hash.new{|h,k| h[k] = []}

# We can perform initialization here
def nuixWorkerItemCallbackInit
	require 'csv'
	CSV.foreach($xref_csv_file, headers: true) do |row|
		parent_guid = row[0].strip.downcase.gsub(/[^a-f0-9]/,"")
		child_path = row[1]
		$xref_data[parent_guid] << child_path
	end
end

# Define our worker item callback
def nuixWorkerItemCallback(worker_item)
	item_guid = worker_item.getItemGuid.strip.downcase.gsub(/[^a-f0-9]/,"")
	if $xref_data.key?(item_guid)
		child_paths = $xref_data[item_guid]
		worker_item.setChildren(child_paths)
	end
end

# We can perform cleanup here if we need to
def nuixWorkerItemCallbackClose
end