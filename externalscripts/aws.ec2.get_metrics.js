var AwsEc2 = {
      params: {},
      request_period: 600,

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

      prepareRecursive: function (prefix, param) {
          var result = {};

          if (typeof param === 'object') {
              if (Array.isArray(param)) {
                  param.forEach(function (value, index) {
                      var nested = AwsEc2.prepareRecursive(prefix + '.member.' + (index + 1), value);
                      Object.keys(nested).forEach(function (key) {
                          result[key] = nested[key];
                      });
                  });
              }
              else {
                  Object.keys(param).forEach(function (k) {
                      var nested = AwsEc2.prepareRecursive(prefix + '.' + k, param[k]);
                      Object.keys(nested).forEach(function (key) {
                          result[key] = nested[key];
                      });
                  });
              }
          }
          else {
              result[prefix] = param;
          }

          return result;
      },

      renderPayload: function (period, instance_id) {
          var metrics_list = [
              'StatusCheckFailed:Count',
              'StatusCheckFailed_Instance:Count',
              'StatusCheckFailed_System:Count',
              'CPUUtilization:Percent',
              'NetworkIn:Bytes',
              'NetworkOut:Bytes',
              'NetworkPacketsIn:Count',
              'NetworkPacketsOut:Count',
              'DiskReadOps:Count',
              'DiskWriteOps:Count',
              'DiskReadBytes:Bytes',
              'DiskWriteBytes:Bytes',
              'MetadataNoToken:Count',
              'CPUCreditUsage:Count',
              'CPUCreditBalance:Count',
              'CPUSurplusCreditBalance:Count',
              'CPUSurplusCreditsCharged:Count',
              'EBSReadOps:Count',
              'EBSWriteOps:Count',
              'EBSReadBytes:Bytes',
              'EBSWriteBytes:Bytes',
              'EBSIOBalance %:Percent',
              'EBSByteBalance %:Percent'
          ];

          var metric_payload = [];
          metrics_list.forEach(function (metric) {
              var parts = metric.split(':', 2);
              var name = parts[0].replace(/[^a-zA-Z0-9]/g, '');
              metric_payload.push({
                  'Id': name.charAt(0).toLowerCase() + name.slice(1),
                  'MetricStat': {
                      'Metric': {
                          'MetricName': parts[0],
                          'Namespace': 'AWS/EC2',
                          'Dimensions': [
                              {
                                  'Name': 'InstanceId',
                                  'Value': instance_id
                              }
                          ]
                      },
                      'Period': period,
                      'Stat': 'Average',
                      'Unit': parts[1]
                  }
              });
          });

          return metric_payload;
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
              host = 'monitoring.' + region + '.amazonaws.com',
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

          Zabbix.log(4, '[ AWC EC2  ] Sending request: ' + url);

          response = request.get(url);

          Zabbix.log(4, '[ AWC EC2 ] Received response with status code ' + request.getStatus() + ': ' + response);

          if (request.getStatus() !== 200) {
              throw 'Request failed with status code ' + request.getStatus() + ': ' + response;
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

      getMetricsData: function () {
          var timestamp = new Date().getTime(),
              end_time = new Date(timestamp).toISOString().replace(/\.\d+Z/, 'Z'),
              start_time = new Date(timestamp - AwsEc2.request_period * 1000).toISOString().replace(/\.\d+Z/, 'Z'),
              payload = AwsEc2.prepareRecursive('MetricDataQueries', AwsEc2.renderPayload(AwsEc2.request_period, AwsEc2.params.instance_id));

          payload['Action'] = 'GetMetricData';
          payload['Version'] = '2010-08-01';
          payload['StartTime'] = start_time;
          payload['EndTime'] = end_time;
          payload['ScanBy'] = 'TimestampDescending';

          result = AwsEc2.request('GET', AwsEc2.params.region, 'monitoring', AwsEc2.prepareParams(payload));

          if (typeof result !== 'object'
                  || typeof result.GetMetricDataResponse !== 'object'
                  || typeof result.GetMetricDataResponse.GetMetricDataResult !== 'object'
                  || typeof result.GetMetricDataResponse.GetMetricDataResult.MetricDataResults !== 'object') {
              throw 'Cannot get metrics data from AWS CloudWatch API. Check debug log for more information.';
          }

          return result.GetMetricDataResponse.GetMetricDataResult.MetricDataResults;
      }
  };

  try {
      AwsEc2.setParams(JSON.parse(value));

      return JSON.stringify(AwsEc2.getMetricsData());
  }
  catch (error) {
      error += (String(error).endsWith('.')) ? '' : '.';
      Zabbix.log(3, '[ AWS EC2 ] ERROR: ' + error);

      return JSON.stringify({'error': error});
  }
