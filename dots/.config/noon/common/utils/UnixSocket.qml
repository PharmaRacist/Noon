import Quickshell.Io

Socket {
    function add(text: string) {
        flush();
        write(text + "\n");
    }
    function reload() {
        connected = false;
        connected = true;
    }
}
