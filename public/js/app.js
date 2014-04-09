$(function(){
    var host = location.origin.replace(/^http/, 'ws');
    host     = host + "/socket";
    var ws   = new WebSocket(host);

    ws.onmessage = function (event) {
        var data = JSON.parse(event.data);
        if (data["ft"] == "counters") {
            updateCounters(data);
        } else {
            if (window.location.pathname.match(/\/event\/(.*)/) != null && data["ft"] == "newvote") {
                // event page
                var hashtag = window.location.pathname.match(/\/event\/(.*)/)[1];
                if (hashtag == data["tk"]) {
                    updateEvent(data);
                }
            }
        }
    };

    var updateCounters = function(data) {
        $("#twtcount").text(data["twt"]);
        $("#rttcount").text(data["rtt"]);
        $("#votcount").text(data["vot"]);
    };

    var updateEvent = function(data) {
        var votes = { 
            "green" : parseInt($("#greenvotes").text()),
            "yellow": parseInt($("#yellowvotes").text()),
            "red"   : parseInt($("#redvotes").text())
        }

        votes[data["rv"]]++;
        var total = votes["green"] + votes["yellow"] + votes["red"];

        $("#"+ data["rv"] +"votes").text(votes[data["rv"]]);
        $("#totalvotes").text(total);
        $("#bargreen").attr("style","width: "+ (votes["green"]/total*100).toFixed(2) +"%");
        $("#baryellow").attr("style","width: "+ (votes["yellow"]/total*100).toFixed(2) +"%");
        $("#barred").attr("style","width: "+ (votes["red"]/total*100).toFixed(2) +"%");
    };
});
