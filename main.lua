require('config')

ip = wifi.sta.getip()

TOPIC = "/sensors/relay/data"

-- Init client with keepalive timer 120sec
m = mqtt.Client(CLIENT_ID, 120, "", "")

m:lwt("/offline", '{"message":"'..CLIENT_ID..'", "topic":"'..TOPIC..'", "ip":"'..ip..'"}', 0, 0)

print("Connecting to MQTT: "..BROKER_IP..":"..BROKER_PORT.."...")
m:connect(BROKER_IP, BROKER_PORT, 0, 1, function(conn)
    print("Connected to MQTT: "..BROKER_IP..":"..BROKER_PORT.." as "..CLIENT_ID)
     m:subscribe(TOPIC, 2, function(m)
        print("Successfully subscribed to the topic: "..TOPIC)
    end)
end)

m:on("message", function(m, topic, data)
    if data then
        uart.setup(0, 9600, 8, 0, 1)
        if data == "ON" then
            uart.write(0, 0xA0, 0x01, 0x01, 0xA2)
        elseif data == "OFF" then
            uart.write(0, 0xA0, 0x01, 0x00, 0xA1)
        elseif data == "RESET" then
            node.restart()
        end
    end
end)
