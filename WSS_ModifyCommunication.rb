=begin

Copyright 2019 Nuix
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

java_import 'nuix.Address'
java_import 'nuix.Communication'

# Class which implements nuix.Address interface
# https://download.nuix.com/releases/desktop/stable/docs/en/scripting/api/nuix/Address.html
class SimpleAddress
	include Address

	def initialize(personal, address)
		@personal = personal
		@address = address
	end

	def getPersonal
		@personal
	end

	def getAddress
		@address
	end

	def getType
		"internet-mail"
	end

	def toRfc822String
		@address
	end

	def toDisplayString
		@address
	end

	def equals(address)
		address == @address
	end
end

# Class which implements nuix.Communication interface
# https://download.nuix.com/releases/desktop/stable/docs/en/scripting/api/nuix/Communication.html
class SimpleCommunication
	include Communication

	def initialize(date_time, from_addresses, to_addresses, cc_addresses, bcc_addresses)
		@date_time = date_time
		@from_addresses = from_addresses
		@to_addresses = to_addresses
		@cc_addresses = cc_addresses
		@bcc_addresses = bcc_addresses
	end

	def getDateTime
		@date_time
	end

	def getFrom
		@from_addresses
	end

	def getTo
		@to_addresses
	end

	def getCc
		@cc_addresses
	end
	
	def getBcc
		@bcc_addresses
	end

	def add_from(personal,address)
		@from_addresses << SimpleAddress.new(personal,address)
	end

	def add_to(personal,address)
		@to_addresses << SimpleAddress.new(personal,address)
	end

	def add_cc(personal,address)
		@cc_addresses << SimpleAddress.new(personal,address)
	end

	def add_bcc(personal,address)
		@bcc_addresses << SimpleAddress.new(personal,address)
	end

	def self.copy_from_existing(communication)
		result = new(communication.getDateTime,communication.getFrom.to_a,communication.getTo.to_a,communication.getCc.to_a,communication.getBcc.to_a)
		return result
	end
end

def nuix_worker_item_callback(worker_item)
	# Get associated source item
	source_item = worker_item.getSourceItem
	# Get existing Communication if item has one
	existing_communication = source_item.getCommunication
	# Do we have a communication to work with?
	if existing_communication.nil? == false
		# Build our own modifiable communication based on the existing one
		modified_communication = SimpleCommunication.copy_from_existing(existing_communication)
		# Add an address to BCC
		modified_communication.add_bcc("Bob Someguy","bob.someguy@company.com")
		# Instruct Nuix to use our modified communication object for this item
		worker_item.setItemCommunication(modified_communication)
	end
end