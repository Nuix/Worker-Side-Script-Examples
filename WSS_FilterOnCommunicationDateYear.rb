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

$min_year = 2001
$max_year = 2001

# Define our worker item callback
def nuix_worker_item_callback(worker_item)

    # Get the associated SourceItem
    source_item = worker_item.getSourceItem

    # Get the communication object
    communication = source_item.getCommunication
    
    # Check that we actually got a communication for this item
    if !communication.nil?
        # Get communication date
        date_time = communication.getDateTime
        # Get the year
        year = date_time.getYear
        # Are we outside our range?
        if year < $min_year || year > $max_year
            # We're outside our range, diable processing this item
            worker_item.setProcessItem(false)
        end
    end
end