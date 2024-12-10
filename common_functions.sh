log_result() {
    local exit_status="$1"
	local file_name="$2"
    local success_message="$3"
    local failure_message="$4"
    local log_file="${5:-quickarch_logs.txt}"

    if [[ $exit_status -eq 0 ]]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') $file_name - $success_message" >> "$log_file"
    else
        echo "$(date '+%Y-%m-%d %H:%M:%S') $file_name - $failure_message" >> "$log_file"
    fi
}
