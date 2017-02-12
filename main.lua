require('config')

ip = wifi.sta.getip()

print('Starting web server')
srv=net.createServer(net.TCP)

gpio.write(DATA_PIN, gpio.HIGH);

srv:listen(80, function(conn)
    conn:on("receive", function(client,request)
        --print(request)        
        local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP");
        if(method == nil)then
            _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP");
        end
        local _GET = {}
        if (vars ~= nil)then
            for k, v in string.gmatch(vars, "(%w+)=(%w+)&*") do
                _GET[k] = v
            end
        end
  
        local _on,_off = "",""
        if(_GET.state == "ON")then
            print('on')
            gpio.write(DATA_PIN, gpio.HIGH);
        elseif(_GET.state == "OFF")then
            print('off')
            gpio.write(DATA_PIN, gpio.LOW);
        elseif(_GET.state == "RST")then
            node.restart();
        end
 
        -- Cloture de la session
        local response = "HTTP/1.1 200 OK\r\n\r\nOK"
        conn:send(response, function()
            conn:close()
        end)
        collectgarbage();        
    end)
end)

