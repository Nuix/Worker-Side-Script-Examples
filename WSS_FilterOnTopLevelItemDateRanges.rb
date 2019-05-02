# Copyright 2019 Nuix

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#     http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This worker side script filters processed items based on whether they are within
# one or more define date ranges.  When an item is top level, it is checked to see
# if it is within one of the define date ranges.  If it is not, the item is not processed.
# If it is, it is processed.  If an item is not top level, this script makes no decision
# as to whether the item should be processed.

$date_ranges = []

# Add some date ranges, parsed by org.joda.time.DateTime constructor
$date_ranges << ["2017-01-01T00:00:00-07:00","2017-01-10T23:59:59-07:00"]
$date_ranges << ["2017-02-01T00:00:00-07:00","2017-02-10T23:59:59-07:00"]
$date_ranges << ["2017-03-01T00:00:00-07:00","2017-03-10T23:59:59-07:00"]

# If an item date is not available for an item
# should we still process it?
$include_if_date_missing = false

# Load the DateTime class so we may define min/max
java_import "org.joda.time.DateTime"

# We can perform initialization here
def nuixWorkerItemCallbackInit
end

# Define our worker item callback
def nuixWorkerItemCallback(worker_item)
	source_item = worker_item.getSourceItem
	# First check if the item is top level
	# SourceItem.isTopLevel is new to Nuix 7.4
	if source_item.isTopLevel
		# It is top level, lets fetch the item date
		# SourceItem.getDate is new to Nuix 7.4
		item_date = source_item.getDate

		# Should we include if no item date could be calculated?
		if item_date.nil?
			worker_item.setProcessItem($include_if_date_missing)
		else
			found_range_hit = false
			$date_ranges.each do |date_range|
				min_date = DateTime.new(date_range[0])
				max_date = DateTime.new(date_range[1])
				# If we have reached here then we do have an item date
				# so lets test if it is within our range
				is_before_range = item_date.isBefore(min_date)
				is_after_range = item_date.isAfter(max_date)
				is_in_range = (is_before_range == false) && (is_after_range == false)
				if is_in_range
					found_range_hit = true
					break
				end
			end
			worker_item.setProcessItem(found_range_hit)
		end
	end
end

# We can perform cleanup here if we need to
def nuixWorkerItemCallbackClose
end