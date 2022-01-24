var obj = JSON.parse(value),
    result = [],
    service = obj.shift(),
    flag = true;

 

while (obj.length > 0) {
    flag = true;
    for (j = 0; j < result.length; j++) {
        if (service['{#VM.DNS}'] === result[j]['{#VM.DNS}'] && service.process === result[j].process) {
            flag = false;
            break;
        }
    };
    if (flag) result.push(service);
    service = obj.shift();
};

return JSON.stringify(result);

