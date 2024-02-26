vcd_file="./signals/signals.vcd"
out_log="./signals/gtkwave.out"
err_log="./signals.gtkwave.err"

nohup gtkwave $vcd_file > $out_log 2> $err_log  &
