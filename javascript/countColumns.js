var lines = value.split('\n');

var sum = 0;
for(i = 0; i < lines.length; i++) {
sum += parseInt(lines[i].split(/\s+/)[1]||0, 10);
Zabbix.log(4, 'sum="' + sum + '"\n' + lines[i] + '\n');
}

return sum;
