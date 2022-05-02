class traceEvent:
    def __init__(self,eventDetailList):
        while len(eventDetailList)< 18:
            eventDetailList.append("")

        self.event_type = eventDetailList[0]
        self.time = float(eventDetailList[1])
        self.node_id = eventDetailList[2]
        self.trace_level = eventDetailList[3]
        self.reason = eventDetailList[4]
        self.packet_unique_id = int(eventDetailList[5])
        self.payload_type = eventDetailList[6]
        self.packet_size = int(eventDetailList[7])
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

def advancedSplitter(string):
    splitedStringList= list()
    substr= str()
    inprogress= False
    endDelimiter= ' '
    for char in string:
        if char== endDelimiter:
            if substr!= "":
                splitedStringList.append(substr)
            substr= ""
            endDelimiter= ' '
            inprogress= False
        elif char== '[' and not inprogress:
            endDelimiter= ']'
            inprogress= True
        elif char== '(' and not inprogress:
            endDelimiter= ')'
            inprogress=True
        elif char== ' ' and not inprogress:
            endDelimiter= ' '
            inprogress= True
        else:
            if char!= '\n':
                substr+= char

    if substr!= "":
        splitedStringList.append(substr)
    return splitedStringList


traceFile =  open('Main.tr')
traceEvents = list()
for line in traceFile:
    if line.split()[0]!= 'M':
        traceEvents.append(traceEvent(advancedSplitter(line)))
