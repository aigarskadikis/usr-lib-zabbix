var AwsEbs = {
    params: {},
    request_period: 600,

    setParams: function (params) {
        ['access_key', 'secret_key', 'region', 'instance_id'].forEach(function (field) {
            if (typeof params !== 'object' || typeof params[field] === 'undefined' || params[field] === '') {
                throw 'Required param is not set: "' + field + '".';
            }
        });

        AwsEbs.params = params;
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
            key = AwsEbs.sign('AWS4' + AwsEbs.params.secret_key, date);

        key = AwsEbs.sign(key, region);
        key = AwsEbs.sign(key, service);
        key = AwsEbs.sign(key, 'aws4_request');

        var request = new HttpRequest(),
            url = 'https://' + host + canonical_uri + '?' + params;

        request.addHeader('x-amz-date: ' + amzdate);
        request.addHeader('Accept: application/json');
        request.addHeader('Content-Type: application/json');
        request.addHeader('Content-Encoding: amz-1.0');
        request.addHeader('Authorization: ' + 'AWS4-HMAC-SHA256 Credential=' + AwsEbs.params.access_key + '/' + credential_scope + ', ' + 'SignedHeaders=' + signed_headers + ', ' + 'Signature=' + hmac('sha256', key, request_string));

        Zabbix.log(4, '[ AWC EBS ] Sending request: ' + url);

        response = request.get(url);

        Zabbix.log(4, '[ AWC EBS ] Received response with status code ' + request.getStatus() + ': ' + response);

        if (request.getStatus() !== 200) {
            throw 'Request failed with status code ' + request.getStatus() + ': ' + response;
        }

        if (response !== null) {
            try {
                response = XML.toJson(response);
            }
            catch (error) {
                throw 'Failed to parse response received from AWS CloudWatch API. Check debug log for more information.';
            }
        }
        response = JSON.parse(response)

        return response;
    },


    getVolumesData: function () {
          var payload = {},
              volumes_list = [],
              result = [];

          payload['Action'] = 'DescribeVolumes',
              payload['MaxResults'] = 100,
              payload['Version'] = '2016-11-15',
              payload['Filter.1.Name'] = 'attachment.instance-id',
              payload['Filter.1.Value'] = AwsEbs.params.instance_id;

          while (payload.NextToken !== '') {
              var volumes = AwsEbs.request('GET', AwsEbs.params.region, 'ec2', AwsEbs.prepareParams(payload));
              if (typeof result !== 'object'
                  || typeof volumes.DescribeVolumesResponse !== 'object'
                  || typeof volumes.DescribeVolumesResponse.volumeSet !== 'object'
                  || typeof volumes.DescribeVolumesResponse.volumeSet.item !== 'object') {
                  throw 'Cannot get metrics data from AWS EC2 API. Check debug log for more information.';
              }
              payload.NextToken = volumes.DescribeVolumesResponse.NextToken || '';
              volumes_list = volumes.DescribeVolumesResponse.volumeSet.item

              if (typeof volumes_list === 'object'
                  && volumes_list !== null
                  && !Array.isArray(volumes_list)) {
                  volumes_list = [volumes_list];
              }

          }

          return volumes_list;
      }
  };

try {
    AwsEbs.setParams(JSON.parse(value));

    return JSON.stringify(AwsEbs.getVolumesData());
}
catch (error) {
    error += (String(error).endsWith('.')) ? '' : '.';
    Zabbix.log(3, '[ AWS EBS ] ERROR: ' + error);

    return JSON.stringify({ 'error': error });
}
