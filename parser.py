class traceEvent:
    def __init__(self,eventDetailList):
        self.event_type = eventDetailList[0]
        self.time = eventDetailList[1]
        self.node_id = eventDetailList[2]
        self.trace_level = eventDetailList[3]
        self.reason = eventDetailList[4]
        self.packet_unique_id = eventDetailList[5]
        self.payload_type = eventDetailList[6]
        self.packet_size = eventDetailList[7]
        self.time_to_send_data = eventDetailList[8]
        self.destination_MAC_address = eventDetailList[9]
        self.source_MAC_address = eventDetailList[10]
        self.Ethernet_packet_type = eventDetailList[11]
        self.blank = eventDetailList[12]
        self.source_ip_address = eventDetailList[13]
        self.source_port_number = eventDetailList[14]
        self.destination_ip_address = eventDetailList[15]
        self.destination_port_number = eventDetailList[16]
        self.time_to_live = eventDetailList[17]


traceFile=  open('try1.tr')
traceEvents= list()
for line in traceFile:
    traceEvents.append(traceEvent(line.split()))

print("Event type: ",traceEvents[0].event_type)
print("Event time: ",traceEvents[0].time)
print("Event nodeId: ",traceEvents[0].node_id)
print("Event traceLevel: ",traceEvents[0].trace_level)
print("Event reason: ",traceEvents[0].reason)
