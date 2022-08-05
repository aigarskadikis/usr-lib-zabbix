var AwsEc2 = {
   params: {},

   setParams: function (params) {
       ['access_key', 'secret_key', 'region', 'instance_id'].forEach(function (field) {
           if (typeof params !== 'object' || typeof params[field] === 'undefined' || params[field] === '') {
               throw 'Required param is not set: "' + field + '".';
           }
       });

       AwsEc2.params = params;
   },

   sign: function (key, message) {
       var hex = hmac('sha256', key, message);

       if ((hex.length % 2) === 1) {
           throw 'Invalid length of a hex string!';
       }

       var result = new Int8Array(hex.length / 2);
       for (var i = 0, b = 0; i < hex.length; i += 2, b++) {
           result[b] = parseInt(hex.substring(i, i + 2), 16);
       }

       return result;
   },

   prepareParams: function (params) {
       var result = [];

       Object.keys(params).sort().forEach(function (key) {
           if (typeof params[key] !== 'object') {
               result.push(key + '=' + encodeURIComponent(params[key]));
           }
           else {
               result.push(prepareObject(key, params[key]));
           }
       });

       return result.join('&');
   },

   request: function (method, region, service, params, data) {
       if (typeof data === 'undefined' || data === null) {
           data = '';
       }

       var amzdate = (new Date()).toISOString().replace(/\.\d+Z/, 'Z').replace(/[-:]/g, ''),
           date = amzdate.replace(/T\d+Z/, ''),
           host = service + '.' + region + '.amazonaws.com',
           canonical_uri = '/',
           canonical_headers = 'content-encoding:amz-1.0\n' + 'host:' + host + '\n' + 'x-amz-date:' + amzdate + '\n',
           signed_headers = 'content-encoding;host;x-amz-date',
           canonical_request = method + '\n' + canonical_uri + '\n' + params + '\n' + canonical_headers + '\n' + signed_headers + '\n' + sha256(data),
           credential_scope = date + '/' + region + '/' + service + '/' + 'aws4_request',
           request_string = 'AWS4-HMAC-SHA256' + '\n' + amzdate + '\n' + credential_scope + '\n' + sha256(canonical_request),
           key = AwsEc2.sign('AWS4' + AwsEc2.params.secret_key, date);

       key = AwsEc2.sign(key, region);
       key = AwsEc2.sign(key, service);
       key = AwsEc2.sign(key, 'aws4_request');

       var request = new HttpRequest(),
           url = 'https://' + host + canonical_uri + '?' + params;

       request.addHeader('x-amz-date: ' + amzdate);
       request.addHeader('Accept: application/json');
       request.addHeader('Content-Type: application/json');
       request.addHeader('Content-Encoding: amz-1.0');
       request.addHeader('Authorization: ' + 'AWS4-HMAC-SHA256 Credential=' + AwsEc2.params.access_key + '/' + credential_scope + ', ' + 'SignedHeaders=' + signed_headers + ', ' + 'Signature=' + hmac('sha256', key, request_string));

       Zabbix.log(4, '[ AWS EC2  ] Sending request: ' + url);

       response = request.get(url);

       Zabbix.log(4, '[ AWS EC2 ] Received response with status code ' + request.getStatus() + ': ' + response);

       if (request.getStatus() !== 200) {
           throw 'Request failed with status code ' + request.getStatus() + ': ' + response;
       }

       if (response[0] === '<') {
           try {
               response = XML.toJson(response);
           }
           catch (error) {
               throw 'Failed to parse response received from AWS CloudWatch API. Check debug log for more information.';
           }
       }

       if (response !== null) {
           try {
               response = JSON.parse(response);
           }
           catch (error) {
               throw 'Failed to parse response received from AWS CloudWatch API. Check debug log for more information.';
           }
       }

       return response;
   },
   getVolumes: function () {
       var payload = {},
           result = [];

       payload['Action'] = 'DescribeVolumes',
           payload['MaxResults'] = 100,
           payload['Version'] = '2016-11-15',
           payload['Filter.1.Name'] = 'attachment.instance-id',
           payload['Filter.1.Value'] = AwsEc2.params.instance_id;

       while (payload.NextToken !== '') {
           var volumes = AwsEc2.request('GET', AwsEc2.params.region, 'ec2', AwsEc2.prepareParams(payload));
           if (typeof result !== 'object'
               || typeof volumes.DescribeVolumesResponse !== 'object'
               || typeof volumes.DescribeVolumesResponse.volumeSet !== 'object'
               || typeof volumes.DescribeVolumesResponse.volumeSet.item !== 'object') {
               throw 'Cannot get metrics data from AWS EC2 API. Check debug log for more information.';
           }
           payload.NextToken = volumes.DescribeVolumesResponse.NextToken || '';
           volumes.DescribeVolumesResponse.volumeSet.item.forEach(function (volume) {
               result.push(volume.volumeId)
           });
       }

       return result;
   },
   getAlarms: function () {
       var payload = {},
           result = [],
           volumes = AwsEc2.getVolumes()

       payload['Action'] = 'DescribeAlarms';
       payload['MaxRecords'] = 100;
       payload['Version'] = '2010-08-01';

       while (payload.NextToken !== '') {
           var alarms = AwsEc2.request('GET', AwsEc2.params.region, 'monitoring', AwsEc2.prepareParams(payload));

           if (typeof alarms !== 'object'
               || typeof alarms.DescribeAlarmsResponse !== 'object'
               || typeof alarms.DescribeAlarmsResponse.DescribeAlarmsResult !== 'object'
               || typeof alarms.DescribeAlarmsResponse.DescribeAlarmsResult.MetricAlarms !== 'object') {
               throw 'Cannot get alarms from AWS CloudWatch API. Check debug log for more information.';
           }

           payload.NextToken = alarms.DescribeAlarmsResponse.DescribeAlarmsResult.NextToken || '';

           alarms.DescribeAlarmsResponse.DescribeAlarmsResult.MetricAlarms.forEach(function (alarm) {
               var dimensions = alarm.Dimensions;

               if (Array.isArray(alarm.Metrics)) {
                   alarm.Metrics.forEach(function (metric) {
                       if (typeof metric.MetricStat === 'object' && metric.MetricStat !== null
                           && typeof metric.MetricStat.Metric === 'object' && metric.MetricStat.Metric !== null
                           && Array.isArray(metric.MetricStat.Metric.Dimensions)) {
                           dimensions = dimensions.concat(metric.MetricStat.Metric.Dimensions);
                       }
                   });
               }
               for (var i in dimensions) {
                   if (dimensions[i].Name === 'InstanceId' && dimensions[i].Value === AwsEc2.params.instance_id) {
                       result.push(alarm);
                       break;
                   }
                   if (dimensions[i].Name === 'VolumeId' && volumes.indexOf(dimensions[i].Value)) {
                       result.push(alarm);
                       break;
                   }
               }
           });
       }

       return result;
   }
 }

 try {
     AwsEc2.setParams(JSON.parse(value));

     return JSON.stringify(AwsEc2.getAlarms());
 }
 catch (error) {
     error += (String(error).endsWith('.')) ? '' : '.';
     Zabbix.log(3, '[ AWS EC2 ] ERROR: ' + error);

     return JSON.stringify({ 'error': error });
 }

