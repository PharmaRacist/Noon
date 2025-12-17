pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import Quickshell
import qs.modules.common

Singleton {
    id: root

    property var quoteData: ({
            text: "Loading...",
            author: "...",
            isLoading: true
        })

    // Add a signal to notify when quote data changes
    signal quoteChanged

    function loadQuote() {
        quoteData = {
            text: "Loading...",
            author: "...",
            isLoading: true
        };

        var xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function () {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    try {
                        var data = JSON.parse(xhr.responseText);
                        // zenquotes returns an array with one object
                        var quote = data[0];
                        quoteData = {
                            text: quote.q,
                            author: quote.a,
                            isLoading: false
                        };
                        quoteChanged(); // Emit signal to notify UI
                    } catch (e) {
                        // Use fallback quote
                        quoteData = {
                            text: "Everything that irritates us about others can lead us to an understanding of ourselves.",
                            author: "Carl Jung",
                            isLoading: false
                        };
                        quoteChanged(); // Emit signal
                    }
                } else {
                    // Use fallback quote
                    quoteData = {
                        text: "Until you make the unconscious conscious, it will direct your life and you will call it fate.",
                        author: "Carl Jung",
                        isLoading: false
                    };
                    quoteChanged(); // Emit signal
                }
            }
        };

        xhr.open("GET", "https://zenquotes.io/api/random");
        xhr.send();
    }

    function refreshQuote() {
        loadQuote();
    }
}
