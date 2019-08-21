/<pre>/ {
    pre = 1
}

{
    if (pre) {
        print $0
    } else {
        gsub(/\s+/, " ", $0);
        printf("%s", $0)
    }
}

/<\/pre>/ {
    pre = 0
}
