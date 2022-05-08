var Particle = require("particle-io");  // see https://github.com/rwaldron/particle-io
var request = require('request');
var osc = require("osc");

// BEGIN OSC SEND TO PROCESSING CODE
var sendPort = new osc.UDPPort({
  localAddress: "0.0.0.0",
  localPort: 6000,
  metadata: false
});

// Open the socket.
sendPort.open();

// sendPort.on("ready", function () {
//   sendPort.send({
//       address: "/s_new",
//       args: [
//           {
//               type: "s",
//               value: "test"
//           }
//       ]
//   }, "172.26.6.92", 6001);
// });

// sendPort.on("ready", function () {
//   sendPort.send({
//       address: "/s_new",
//       args: [
//           {
//               type: "s",
//               value: "test"
//           }
//       ]
//   }, "172.26.6.92", 6001);
// });

// END OSC SEND TO PROCESSING CODE

console.log("checked required packages!");

var lastPublishAt = 0

// set up to receive streaming OSC data from Muse Monitor app on phone
var udpPort = new osc.UDPPort({
    localAddress: "0.0.0.0",  // will automatically look locally
    // set address on muse to: 172.26.6.92
    // ^^ get this address from network in system preferences (under WIFI tab IP address)
    localPort: 5000,          // should match streaming port set in Muse Monitor
    metadata: true
});

console.log("Device Ready..");

udpPort.open();

udpPort.on("ready", function () {
  // console.log("ready");
 udpPort.on("message", function (oscMsg) {
  //  console.log("message")

   var address = oscMsg.address;
  //  console.log(address)
   if(address.includes("/muse/elements/beta_absolute")){
     var beta = oscMsg.args[0].value;

     tnow = new Date().getTime()
     if( lastPublishAt + 2000 < tnow ){
		  // console.log(typeof value); --> number

      console.log("raw");
      console.log(beta);

      if (beta < 0) {}
      else {
        val = scale(beta * 100, 35, 200, 0, 5)
        if (val < 0) {}
        else if (val > 5) {}
        else {
          abstraction = parseInt(scale(val, 0, 5, 2, 80))
          
          console.log("abstraction");
          console.log(abstraction);
          
          sendPort.send({
            address: "/abstraction",
            args: [
                {
                    type: "i",
                    value: abstraction,
                }
            ]
        }, "127.0.0.1", 6001);
        }
      }
        lastPublishAt = tnow;
     }
   }
 });
});

function scale (number, inMin, inMax, outMin, outMax) {
  return (number - inMin) * (outMax - outMin) / (inMax - inMin) + outMin;
}