import parser

tr_list = parser.traceEvents

recvdSize = 0
startTime = 0
stopTime = 7
tr_len = len(tr_list)

for i in range(tr_len-1):
    if (tr_list[i].payload_type == "tcp") and (tr_list[i].event_type == "s") and (tr_list[i+1].event_type == "r") and (tr_list[i].packet_size >= 100):
        if tr_list[i].time < startTime:
            startTime = tr_list[i].time
        if tr_list[i].time > stopTime:
            stopTime = tr_list[i].time
        recvdSize += tr_list[i].packet_size

goodput = (recvdSize / (stopTime - startTime)) * 8 / 10**6

print("Average Goodput :", round(goodput,2), "[Mbps]\t\t", " strat time :", round(startTime,2), "\t" " stop time :", round(stopTime,2))