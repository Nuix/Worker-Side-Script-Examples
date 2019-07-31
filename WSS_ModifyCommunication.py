#
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
#
# Visit GitHub for more examples: https://github.com/Nuix/Worker-Side-Script-Examples
#
# This WSS demonstrates customizing the Communication object of an item being processed.  This
# script defines 2 classes:
#
# - SimpleAddress: A Python class implementing the Nuix interface Address (https://download.nuix.com/releases/desktop/stable/docs/en/scripting/api/nuix/Address.html)
# - SimpleCommunication: A Python class implementing the Nuix interface Communication (https://download.nuix.com/releases/desktop/stable/docs/en/scripting/api/nuix/Communication.html)
#
# We use these 2 classes to then build a customized communication object and ultimately provide that back to Nuix
# using the method WorkerItem.setItemCommunication which will replace any communication originally present
# on the item with the one we created.
#


from org.joda.time import DateTime
from nuix import Address
from nuix import Communication

class SimpleAddress (Address):
    def __init__(self, personal, address):
      self._address = address
      self._personal = personal
    
    def getPersonal(self):
        return self._personal

    def getAddress(self):
        return self._address

    def getType(self):
        return "internet-mail"

    def toRfc822String(self):
        return self._address

    def toDisplayString(self):
        return self._address

    def equals(self, address):
        return address == self._address        

class SimpleCommunication (Communication):
    def __init__(self, date_time, from_addresses, to_addresses, cc_addresses, bcc_addresses):
        self._date_time = date_time
        self._from_addresses = from_addresses
        self._to_addresses = to_addresses
        self._cc_addresses = cc_addresses
        self._bcc_addresses = bcc_addresses

    def getDateTime(self):
        return self._date_time

    def getFrom(self):
        return self._from_addresses

    def getTo(self):
        return self._to_addresses

    def getCc(self):
        return self._cc_addresses

    def getBcc(self):
        return self._bcc_addresses
        

def nuix_worker_item_callback(worker_item):
    source_item = worker_item.getSourceItem()
    if source_item.getName() == 'test.txt':
        comm = SimpleCommunication(DateTime.now(), [SimpleAddress("David Skysits", "david.skysits@company.com")], [SimpleAddress("Stephen Artstew", "stephen.artstew@company.com")], [], [])
        worker_item.setItemCommunication(comm)
