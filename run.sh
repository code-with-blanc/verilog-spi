# project configuration
project_name="spc"
source_dir="./src"
source_files="spc.v spi_controller.v spc_tb.v"
script_name=$(basename "$0")

# generate internally needed variables
source_files_with_dir=$(printf "$source_dir/%s " $source_files)
build_output="./build/$project_name.out"

echo "[$script_name][Start] Cleaning previous build result"
rm "$build_output"
echo "[$script_name][Done]  Cleaning previous build result"

echo "[$script_name][Start] Compiling project"
iverilog $source_files_with_dir -o "$build_output"
iverilog_output=$?
echo "[$script_name][Done]  Compiling project"

if [ $iverilog_output -ne 0 ]; then
        echo "[$script_name][Error] Compilation failed (exit code $iverilog_output)."
        exit $?
fi

printf "[$script_name][Start] Simulating\n ---------\n"
vvp "$build_output"
printf " ---------\n[$script_name][Done]  Simulating\n"
