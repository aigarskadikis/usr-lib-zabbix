var obj = JSON.parse('{"jsonrpc":"2.0","error":{"code":-32500,"message":"Application error.","data":"Login name or password is incorrect."},"id":1}');

if ( obj.error ) { return 1 } else { return 0 }
