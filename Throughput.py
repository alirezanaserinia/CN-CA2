import parser

tr_list = parser.traceEvents

recv = 0
gotime = 1
time_interval = 1

tr_len = len(tr_list)

f = open("ThroughputGraph.txt", "w")

for i in range(tr_len):
    if (tr_list[i].event_type == "r") and (tr_list[i].trace_level == "AGT") and (tr_list[i].payload_type == "tcp"):
        recv += 1

    time = tr_list[i].time
    packet_size = tr_list[i].packet_size
    
    if time > gotime:
        #print(gotime, (packet_size * recv * 8.0 / 1000))
        momentary_throughput = round(packet_size * recv * 8.0 / 1000, 3)
        line_str = str(gotime) + " " + str(momentary_throughput) + "\n"
        f.write(line_str)
        gotime += time_interval
        recv = 0
        

f.close()

