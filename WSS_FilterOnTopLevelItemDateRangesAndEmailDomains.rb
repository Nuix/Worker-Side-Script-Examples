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

# This worker side script filters items based on:
# 1. Is a given top level item within one of the specified date ranges?
# 2. If the given top level item is an email, does it have at least one
#    of the specified domain addresses?

$date_ranges = []

# Add some date ranges, parsed by org.joda.time.DateTime constructor
$date_ranges << ["2000-01-01T00:00:00-07:00","2000-12-31T23:59:59-07:00"]
$date_ranges << ["2002-01-01T00:00:00-07:00","2002-12-31T23:59:59-07:00"]

# List of email address domain names you would like to filter emails on, note
# that a given email must first be top level and meet the above define date ranges
# before domains are even checked.
# The following example would require that an email have a FROM address like
# NAME@place.net or a TO address like NAME@company.com
#
# $from_domains = ["place.net"]
# $to_domains = ["company.com"]
# $cc_domains = []
# $bcc_domains = []

$from_domains = []
$to_domains = []
$cc_domains = []
$bcc_domains = []

# If an item date is not available for an item
# should we still process it?
$include_if_date_missing = false

# Load the DateTime class so we may define min/max
java_import "org.joda.time.DateTime"

# Convert string addresses to REGEX
$from_domains = $from_domains.map{|d| /#{Regexp.escape(d)}/i}
$to_domains = $to_domains.map{|d| /#{Regexp.escape(d)}/i}
$cc_domains = $cc_domains.map{|d| /#{Regexp.escape(d)}/i}
$bcc_domains = $bcc_domains.map{|d| /#{Regexp.escape(d)}/i}

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

		meets_date_range_requirements = false

		# Should we include if no item date could be calculated?
		if item_date.nil?
			meets_date_range_requirements = $include_if_date_missing
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
					# puts "#{source_item.getLocalisedName} with date #{item_date} is within range #{min_date} - #{max_date}"
					break
				end
			end
			meets_date_range_requirements = found_range_hit
		end

		if meets_date_range_requirements == false
			worker_item.setProcessItem(false)
		else
			# If we reach here, date range passed our test, so we will check if this is an email.  If the
			# given item is not an email, then we pass it because it meets the date range.  If it is an email
			# we need to further qualify it by checking the domains.
			if source_item.isKind("email") == false
				worker_item.setProcessItem(true)
			else
				# Check domains since this is indeed an email
				comm = source_item.getCommunication

				if any_domain_matches($from_domains,comm.getFrom) || any_domain_matches($to_domains,comm.getTo) ||
					any_domain_matches($cc_domains,comm.getCc) || any_domain_matches($bcc_domains,comm.getBcc)
					worker_item.setProcessItem(true)
					# puts "#{source_item.getLocalisedName} has a domain which meets requirements"
				else
					worker_item.setProcessItem(false)
					# puts "#{source_item.getLocalisedName} has no domains which meets requirements"
				end
			end
		end
	end
end

# We can perform cleanup here if we need to
def nuixWorkerItemCallbackClose
end

# Test a collection of domain regular expressions against a collection of
# addresses.  If there are any matches, return true.  If there are no matches
# then return false.  Call to any? should immediately return true the first
# time there is a match.  Worst case there are no matches and all addresses are
# compared before determining there is no match.
def any_domain_matches(domain_regexes,addresses)
	return addresses.map{|a|a.getAddress}.any? do |address|
		next domain_regexes.any?{|r| address =~ r}
	end
end