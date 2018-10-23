# run-with-color.sh

red=31
yellow=33
cyan=36

colored() {
    color=$1
    shift
    echo -e "\033[1;${color}m$@\033[0m"
}

run() {
    "$@"
    result=$?

    if [ $result -ne 0 ]; then
        echo -n $(colored $red "Faild: ")
        echo -n $(colored $cyan "$0")
        echo $(colored $yellow " [$PWD]")
        exit $result
    fi
    return 0
}
