set terminal png
set output 'ThrouputGraph.png'
set xrange [0.0:100.0]
set xlabel "Time(in seconds)"
set autoscale
set yrange [0:2500]
set ylabel "Throughput(in Kbps)"
set grid
set style data linespoints
plot "ThroughputGraph.txt" using 1:2 title "TCP Throughput" lt rgb "blue"

