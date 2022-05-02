import parser

tr_list = parser.traceEvents


seqno = -1 
count = 0

tr_len = len(tr_list)

startTimes = [-1] * tr_len
endTimes = [-1] * tr_len
delay = [-1] * tr_len


for i in range(tr_len):
    if(tr_list[i].trace_level == "AGT" and tr_list[i].event_type == "s" and seqno < tr_list[i].packet_unique_id):
        seqno = tr_list[i].packet_unique_id
    if(tr_list[i].trace_level == "AGT" and tr_list[i].event_type == "s"):
        startTimes[tr_list[i].packet_unique_id] = tr_list[i].time
    elif(tr_list[i].payload_type == "tcp" and tr_list[i].event_type == "r"): 
        endTimes[tr_list[i].packet_unique_id] = tr_list[i].time
    elif(tr_list[i].event_type == "D" and tr_list[i].payload_type == "tcp"):
        endTimes[tr_list[i].packet_unique_id] = -1

for i in range(seqno+1):
    if(endTimes[i] > 0):
        delay[i] = endTimes[i] - startTimes[i]
        count += 1
    else:
        delay[i] = -1

e2e_delays = 0
for i in range(seqno+1):
    if(delay[i] > 0):
        e2e_delays += delay[i]
        
e2e_delay = e2e_delays/count   

print("Average RTT : ", round(2 * e2e_delay * 1000, 2), " ms")