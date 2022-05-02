import parser

tr_list = parser.traceEvents

sendPkt = 0
recvPkt = 0

tr_len = len(tr_list)

for i in range(tr_len):
    if (tr_list[i].event_type == "s") and (tr_list[i].trace_level == "AGT"):
        sendPkt += 1
    elif (tr_list[i].event_type == "r") and (tr_list[i].trace_level == "AGT"):
        recvPkt += 1
    
print("Packet Delivery Ratio is :", round(recvPkt/sendPkt * 100, 3), "%")