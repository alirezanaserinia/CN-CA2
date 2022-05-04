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


tr_len = len(traceEvents)

# For AvgE2EDelay and AvgRTT
E2E_seqno = -1 
E2E_count = 0
E2E_startTimes = [-1] * tr_len
E2E_endTimes = [-1] * tr_len
E2E_delay = [-1] * tr_len

# For AvgGoodput
AvgGoodput_recvdSize = 0
AvgGoodput_startTime = 0
AvgGoodput_stopTime = 7

# For AvgThroughput
AvgThroughput_recvdSize = 0
AvgThroughput_startTime = 0
AvgThroughput_stopTime = 7

# For PDR
PDR_sendPkt = 0
PDR_recvPkt = 0

for i in range(tr_len):
    if(traceEvents[i].trace_level == "AGT" and traceEvents[i].event_type == "s" and E2E_seqno < traceEvents[i].packet_unique_id):
        E2E_seqno = traceEvents[i].packet_unique_id
    if(traceEvents[i].trace_level == "AGT" and traceEvents[i].event_type == "s"):
        E2E_startTimes[traceEvents[i].packet_unique_id] = traceEvents[i].time
    elif(traceEvents[i].payload_type == "tcp" and traceEvents[i].event_type == "r"): 
        E2E_endTimes[traceEvents[i].packet_unique_id] = traceEvents[i].time
    elif(traceEvents[i].event_type == "D" and traceEvents[i].payload_type == "tcp"):
        E2E_endTimes[traceEvents[i].packet_unique_id] = -1
        
    if (traceEvents[i].payload_type == "tcp") and (traceEvents[i].event_type == "s") and (i != tr_len - 1) and (traceEvents[i+1].event_type == "r") and (traceEvents[i].packet_size >= 100):
        if traceEvents[i].time < AvgGoodput_startTime:
            AvgGoodput_startTime = traceEvents[i].time
        if traceEvents[i].time > AvgGoodput_stopTime:
            AvgGoodput_stopTime = traceEvents[i].time
        AvgGoodput_recvdSize += traceEvents[i].packet_size
        
    if (traceEvents[i].payload_type == "tcp") and (traceEvents[i].event_type == "r") and (traceEvents[i].packet_size >= 100):
        if traceEvents[i].time < AvgThroughput_startTime:
            AvgThroughput_startTime = traceEvents[i].time
        if traceEvents[i].time > AvgThroughput_stopTime:
            AvgThroughput_stopTime = traceEvents[i].time
        AvgThroughput_recvdSize += traceEvents[i].packet_size
        
    if (traceEvents[i].event_type == "s") and (traceEvents[i].trace_level == "AGT"):
        PDR_sendPkt += 1
    elif (traceEvents[i].event_type == "r") and (traceEvents[i].trace_level == "AGT"):
        PDR_recvPkt += 1

for i in range(E2E_seqno + 1):
    if(E2E_endTimes[i] > 0):
        E2E_delay[i] = E2E_endTimes[i] - E2E_startTimes[i]
        E2E_count += 1
    else:
        E2E_delay[i] = -1
        
e2e_delays = 0
for i in range(E2E_seqno + 1):
    if(E2E_delay[i] > 0):
        e2e_delays += E2E_delay[i]
        
e2e_delay = e2e_delays/E2E_count  
RTT = e2e_delay * 2 

goodput = (AvgGoodput_recvdSize / (AvgGoodput_stopTime - AvgGoodput_startTime)) * 8 / 10**6
throughput = (AvgThroughput_recvdSize / (AvgThroughput_stopTime - AvgThroughput_startTime)) * 8 / 10**6

print("Average Throughput :", round(throughput,4), "[Mbps]\t\t", " strat time :", round(AvgThroughput_startTime,2), "\t" " stop time :", round(AvgThroughput_stopTime,2))
print("Packet Delivery Ratio is :", round(PDR_recvPkt/PDR_sendPkt * 100, 3), "%")
print("Average End-to-End Delay : ", round(e2e_delay * 1000, 3), " ms")
print("Average RTT : ", round(RTT * 1000, 3), " ms")
print("Average Goodput :", round(goodput,4), "[Mbps]\t\t", " strat time :", round(AvgGoodput_startTime,2), "\t" " stop time :", round(AvgGoodput_stopTime,2))





